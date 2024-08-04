import gleam/dynamic
import gleam/int
import gleam/io
import gleam/json
import gleam/regex
import guido/types
import simplifile

const config_version = 2

fn verify_config_version() -> Bool {
  let assert Ok(config_as_string) = simplifile.read("./Guido.json")
  let assert Ok(re) = regex.from_string("\"config_version\": (\\d+)")
  let changed =
    regex.replace(
      re,
      config_as_string,
      "\"config_version\": " <> int.to_string(config_version),
    )

  // io.println("config_as_string: \n" <> config_as_string)
  // io.println("changed: \n" <> changed)
  config_as_string == changed
}

pub fn load() {
  case verify_config_version() {
    False -> {
      io.println_error(
        "The configversion in Guido.json is not meant for this version of Guido. Please update it to 2.",
      )
      panic
    }
    True -> {
      let assert Ok(config_as_string) = simplifile.read("./Guido.json")
      bot_config_json_decode(config_as_string)
    }
  }
}

pub fn bot_config_json_decode(s: String) {
  dynamic.decode4(
    types.BotConfig,
    dynamic.field("config_version", dynamic.int),
    dynamic.field("token", dynamic.string),
    dynamic.field("bot_id", dynamic.int),
    dynamic.field(
      "bot",
      dynamic.decode4(
        types.BotConfigBot,
        dynamic.field("nickname", dynamic.string),
        dynamic.field("prefix", dynamic.string),
        dynamic.field("owner", dynamic.string),
        dynamic.field("admins", dynamic.list(dynamic.string)),
      ),
    ),
  )
  |> json.decode(s, _)
}
