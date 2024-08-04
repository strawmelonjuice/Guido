// this file was generated via "gleam run -m glerd"

import glerd/types

pub const record_info = [
  #(
    "BotConfig",
    "guido/types",
    [
      #("configversion", types.IsInt), #("token", types.IsString),
      #("bot_id", types.IsInt), #("bot", types.IsRecord("BotConfigBot")),
    ],
    "",
  ),
  #(
    "BotConfigBot",
    "guido/types",
    [
      #("nickname", types.IsString), #("prefix", types.IsString),
      #("owner", types.IsString), #("admins", types.IsList(types.IsString)),
    ],
    "",
  ),
]
