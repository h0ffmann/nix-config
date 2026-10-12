//// What the page reads: `history.json` (written by `history.py`) and the GitHub API.

import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

pub type Commit {
  Commit(
    sha: String,
    date: String,
    subject: String,
    pr: Option(Int),
    bot: Bool,
    added: Int,
    deleted: Int,
  )
}

pub type Era {
  Era(
    title: String,
    blurb: String,
    from: String,
    to: String,
    commits: List(Commit),
  )
}

pub type History {
  History(repo: String, labs: List(#(String, String)), eras: List(Era))
}

pub type Repo {
  Repo(
    name: String,
    html_url: String,
    description: Option(String),
    stars: Int,
    issues: Int,
    size: Int,
    pushed_at: String,
    archived: Bool,
    fork: Bool,
  )
}

/// One entry of a GitHub contents listing.
pub type File {
  File(name: String, html_url: String, download_url: Option(String))
}

fn commit() -> decode.Decoder(Commit) {
  use sha <- decode.field("sha", decode.string)
  use date <- decode.field("date", decode.string)
  use subject <- decode.field("subject", decode.string)
  use pr <- decode.field("pr", decode.optional(decode.int))
  use bot <- decode.field("bot", decode.bool)
  use added <- decode.field("added", decode.int)
  use deleted <- decode.field("deleted", decode.int)
  decode.success(Commit(sha:, date:, subject:, pr:, bot:, added:, deleted:))
}

fn era() -> decode.Decoder(Era) {
  use title <- decode.field("title", decode.string)
  use blurb <- decode.field("blurb", decode.string)
  use from <- decode.field("from", decode.string)
  use to <- decode.field("to", decode.string)
  use commits <- decode.field("commits", decode.list(commit()))
  decode.success(Era(title:, blurb:, from:, to:, commits:))
}

fn history() -> decode.Decoder(History) {
  use repo <- decode.field("repo", decode.string)
  use labs <- decode.field("labs", decode.dict(decode.string, decode.string))
  use eras <- decode.field("eras", decode.list(era()))
  // A dict forgets order; history.py writes the labs sorted by name.
  let labs =
    dict.to_list(labs) |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
  decode.success(History(repo:, labs:, eras:))
}

fn repo() -> decode.Decoder(Repo) {
  use name <- decode.field("name", decode.string)
  use html_url <- decode.field("html_url", decode.string)
  use description <- decode.field("description", decode.optional(decode.string))
  use stars <- decode.field("stargazers_count", decode.int)
  use issues <- decode.field("open_issues_count", decode.int)
  use size <- decode.field("size", decode.int)
  use pushed_at <- decode.field("pushed_at", decode.string)
  use archived <- decode.field("archived", decode.bool)
  use fork <- decode.field("fork", decode.bool)
  decode.success(Repo(
    name:,
    html_url:,
    description:,
    stars:,
    issues:,
    size:,
    pushed_at:,
    archived:,
    fork:,
  ))
}

fn file() -> decode.Decoder(File) {
  use name <- decode.field("name", decode.string)
  use html_url <- decode.field("html_url", decode.string)
  use download_url <- decode.field(
    "download_url",
    decode.optional(decode.string),
  )
  decode.success(File(name:, html_url:, download_url:))
}

fn parse(
  body: String,
  decoder: decode.Decoder(a),
  what: String,
) -> Result(a, String) {
  json.parse(body, decoder)
  |> result.replace_error("Could not read " <> what <> ".")
}

pub fn parse_history(body: String) -> Result(History, String) {
  parse(body, history(), "history.json")
}

pub fn parse_repos(body: String) -> Result(List(Repo), String) {
  parse(body, decode.list(repo()), "the repository list")
}

pub fn parse_listing(body: String) -> Result(List(File), String) {
  parse(body, decode.list(file()), "the readiness directory")
}
