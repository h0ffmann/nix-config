//// The lab's smoke test: Gleam compiles to JavaScript, node runs it, esbuild bundles it.
//// No Hex dependencies, so it builds in the Nix sandbox.

@external(javascript, "./smoke_ffi.mjs", "log")
fn log(line: String) -> Nil

pub fn page(title: String) -> String {
  "<!doctype html><title>" <> title <> "</title><h1>" <> title <> "</h1>"
}

pub fn main() -> Nil {
  log(page("gleam-website smoke"))
}
