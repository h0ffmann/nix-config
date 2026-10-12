//// The HTML document around the application.

import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn document(body: Element(msg)) -> Element(msg) {
  let meta = fn(name, content) {
    html.meta([attribute.name(name), attribute.content(content)])
  }
  let stylesheet = fn(href) {
    html.link([attribute.rel("stylesheet"), attribute.href(href)])
  }
  html.html([attribute.lang("en")], [
    html.head([], [
      html.meta([attribute.charset("utf-8")]),
      meta("viewport", "width=device-width, initial-scale=1"),
      html.title([], "picasso"),
      meta(
        "description",
        "picasso (formerly nix-config): Nix labs, a NixOS system and its history, and the ouroboric-dev standings.",
      ),
      html.link([
        attribute.rel("preconnect"),
        attribute.href("https://fonts.googleapis.com"),
      ]),
      html.link([
        attribute.rel("preconnect"),
        attribute.href("https://fonts.gstatic.com"),
        attribute.crossorigin(""),
      ]),
      stylesheet(
        "https://fonts.googleapis.com/css2?family=Fjalla+One&family=Inter:wght@400;600&family=JetBrains+Mono&display=swap",
      ),
      stylesheet("style.css"),
      // A module script is deferred, so <body> is parsed before the app mounts on it.
      html.script([attribute.type_("module"), attribute.src("app.js")], ""),
    ]),
    html.body([], [body]),
  ])
}
