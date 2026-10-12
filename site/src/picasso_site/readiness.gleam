//// The ouroboric-dev readiness assessment: a markdown file with a `# title`, a
//// `**Bottom line: …**` and a table whose rows start with an id such as `OP-3`.

import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order.{type Order}
import gleam/regexp
import gleam/string

pub type Status {
  Met
  Partial
  Missing
  Other(String)
}

pub type Item {
  Item(
    id: String,
    question: String,
    status: Status,
    evidence: String,
    to_close: String,
  )
}

pub type Readiness {
  Readiness(title: String, bottom: String, items: List(Item))
}

pub const statuses = [Met, Partial, Missing]

pub fn status_name(status: Status) -> String {
  case status {
    Met -> "met"
    Partial -> "partial"
    Missing -> "missing"
    Other(name) -> name
  }
}

fn status(name: String) -> Status {
  case string.lowercase(name) {
    "met" -> Met
    "partial" -> Partial
    "missing" -> Missing
    other -> Other(other)
  }
}

fn first_group(pattern: String, multi_line: Bool, md: String) -> String {
  let options = regexp.Options(case_insensitive: False, multi_line:)
  let assert Ok(re) = regexp.compile(pattern, options)
  case regexp.scan(re, md) {
    [regexp.Match(submatches: [Some(group), ..], ..), ..] -> group
    _ -> ""
  }
}

pub fn parse(md: String) -> Readiness {
  let assert Ok(row) = regexp.from_string("^\\|\\s*[A-Z]{2}-\\d+\\s*\\|")
  let items =
    string.split(md, "\n")
    |> list.filter(regexp.check(row, _))
    |> list.filter_map(fn(line) {
      let cells = string.split(line, "|") |> list.map(string.trim)
      // The leading and trailing pipes leave an empty cell at each end.
      case list.drop(cells, 1) {
        [id, question, status_cell, evidence, to_close, ..] ->
          Ok(
            Item(
              id:,
              question:,
              status: status(status_cell),
              evidence:,
              to_close: case to_close {
                "—" -> ""
                _ -> to_close
              },
            ),
          )
        _ -> Error(Nil)
      }
    })
  Readiness(
    title: first_group("^#\\s+(.+)$", True, md),
    bottom: first_group("\\*\\*Bottom line:\\s*(.+?)\\*\\*", False, md),
    items:,
  )
}

pub fn count(items: List(Item), status: Status) -> Int {
  list.count(items, fn(i) { i.status == status })
}

fn rank(status: Status) -> Int {
  case status {
    Missing -> 0
    Partial -> 1
    Met -> 2
    Other(_) -> 3
  }
}

/// `OP-10` after `OP-9`, as `localeCompare` with `numeric: true` orders them.
pub fn compare_ids(a: String, b: String) -> Order {
  case string.split_once(a, "-"), string.split_once(b, "-") {
    Ok(#(pa, na)), Ok(#(pb, nb)) ->
      case string.compare(pa, pb), int.parse(na), int.parse(nb) {
        order.Eq, Ok(x), Ok(y) -> int.compare(x, y)
        order.Eq, _, _ -> string.compare(na, nb)
        other, _, _ -> other
      }
    _, _ -> string.compare(a, b)
  }
}

/// Missing first, then partial, then met: what is left to do leads.
pub fn sorted(items: List(Item)) -> List(Item) {
  list.sort(items, fn(a, b) {
    int.compare(rank(a.status), rank(b.status))
    |> order.break_tie(compare_ids(a.id, b.id))
  })
}
