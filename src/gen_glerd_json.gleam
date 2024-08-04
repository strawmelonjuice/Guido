import glerd_gen
import glerd_json

pub fn main() {
  glerd_gen.record_info
  |> glerd_json.generate("src", _)
}
