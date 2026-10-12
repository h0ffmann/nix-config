//// Just enough markdown for the readiness table's cells: links, `code` and **bold**.

import gleam/list
import gleam/option.{Some}
import gleam/regexp
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import picasso_site/ffi

const token = "\\[([^\\]]+)\\]\\(([^)\\s]+)\\)|`([^`]+)`|\\*\\*([^*]+)\\*\\*"

const token_bare = "\\[[^\\]]+\\]\\([^)\\s]+\\)|`[^`]+`|\\*\\*[^*]+\\*\\*"

/// Relative links resolve against `base`, the assessment's own URL on GitHub.
pub fn inline(md: String, base: String) -> List(Element(msg)) {
  let assert Ok(tokens) = regexp.from_string(token)
  // Splitting on the same pattern without groups leaves the text between the tokens.
  let assert Ok(gaps) = regexp.from_string(token_bare)
  let texts = regexp.split(gaps, md)
  let matches = regexp.scan(tokens, md)
  interleave(texts, matches, base, [])
}

fn interleave(
  texts: List(String),
  matches: List(regexp.Match),
  base: String,
  acc: List(Element(msg)),
) -> List(Element(msg)) {
  case texts, matches {
    [text, ..texts], [match, ..matches] ->
      interleave(texts, matches, base, [render(match, base), plain(text), ..acc])
    [text, ..], [] -> list.reverse([plain(text), ..acc])
    [], _ -> list.reverse(acc)
  }
  |> list.filter(fn(el) { el != element.none() })
}

fn plain(text: String) -> Element(msg) {
  case text {
    "" -> element.none()
    _ -> html.text(text)
  }
}

fn render(match: regexp.Match, base: String) -> Element(msg) {
  case match.submatches {
    [Some(text), Some(href), ..] ->
      html.a([attribute.href(ffi.resolve_url(href, base))], inline(text, base))
    [_, _, Some(code), ..] -> html.code([], [html.text(code)])
    [_, _, _, Some(bold)] -> html.strong([], [html.text(bold)])
    _ -> html.text(match.content)
  }
}
