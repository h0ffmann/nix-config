//// The original one-line drawings in `static/drawings/`, made for this repository in homage
//// to Picasso. Never add a reproduction of his work (AGENTS.md).

import gleam/int
import gleam/list

pub type Drawing {
  Drawing(name: String, alt: String)
}

pub const all = [
  Drawing("dove", "A dove, one line, after Picasso"),
  Drawing("bull", "A bull, one line, after Picasso"),
  Drawing("face", "A face seen from two sides at once, one line, after Picasso"),
  Drawing("owl", "An owl, one line, after Picasso"),
  Drawing("guitar", "A cubist guitar, one line, after Picasso"),
  Drawing("cat", "A seated cat, one line, after Picasso"),
]

pub const first = Drawing("dove", "A dove, one line, after Picasso")

pub fn src(drawing: Drawing) -> String {
  "drawings/" <> drawing.name <> ".svg"
}

/// Any drawing but the one on screen, so "Another" always changes it.
pub fn other_than(current: Drawing) -> Drawing {
  let others = list.filter(all, fn(d) { d != current })
  case list.drop(others, int.random(list.length(others))) {
    [drawing, ..] -> drawing
    [] -> current
  }
}
