import lustre
import picasso_site/app

pub fn main() -> Nil {
  let assert Ok(_) =
    lustre.application(app.init, app.update, app.view)
    |> lustre.start("body", Nil)
  Nil
}
