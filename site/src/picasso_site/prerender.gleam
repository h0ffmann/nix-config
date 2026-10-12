//// `gleam run -m picasso_site/prerender > dist/index.html`: the page before any data arrives,
//// which the client then takes over in place.

import gleam/io
import lustre/element
import picasso_site/app
import picasso_site/page

pub fn main() -> Nil {
  app.initial()
  |> app.view
  |> page.document
  |> element.to_document_string
  |> io.println
}
