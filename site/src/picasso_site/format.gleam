import gleam/float
import gleam/int
import gleam/list
import gleam/string

/// 12345 -> "12,345", as Intl.NumberFormat('en') writes it.
pub fn thousands(n: Int) -> String {
  let digits = int.to_string(int.absolute_value(n))
  let grouped =
    digits
    |> string.reverse
    |> string.to_graphemes
    |> list.sized_chunk(3)
    |> list.map(string.concat)
    |> string.join(",")
    |> string.reverse
  case n < 0 {
    True -> "-" <> grouped
    False -> grouped
  }
}

/// A repository size from the GitHub API, which counts kilobytes.
pub fn size(kb: Int) -> String {
  case kb >= 1024 {
    True -> {
      let tenths = float.round(int.to_float(kb) /. 102.4)
      int.to_string(tenths / 10) <> "." <> int.to_string(tenths % 10) <> " MB"
    }
    False -> int.to_string(kb) <> " KB"
  }
}

/// Every "YYYY-MM" from `first` to `last`, both included.
pub fn months(first: String, last: String) -> List(String) {
  case month_index(first), month_index(last) {
    Ok(a), Ok(b) -> span(b, a, [])
    _, _ -> []
  }
}

fn span(index: Int, first: Int, acc: List(String)) -> List(String) {
  case index < first {
    True -> acc
    False -> span(index - 1, first, [month_name(index), ..acc])
  }
}

fn month_index(month: String) -> Result(Int, Nil) {
  case string.split(month, "-") {
    [year, m, ..] ->
      case int.parse(year), int.parse(m) {
        Ok(y), Ok(m) -> Ok(y * 12 + m - 1)
        _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn month_name(index: Int) -> String {
  int.to_string(index / 12)
  <> "-"
  <> string.pad_start(int.to_string(index % 12 + 1), 2, "0")
}

pub fn plural(n: Int, word: String) -> String {
  int.to_string(n)
  <> " "
  <> word
  <> case n {
    1 -> ""
    _ -> "s"
  }
}
