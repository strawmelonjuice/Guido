pub type BotConfigBot {
  BotConfigBot(
    nickname: String,
    prefix: String,
    owner: String,
    admins: List(String),
  )
}

pub type BotConfig {
  BotConfig(config_version: Int, token: String, bot_id: Int, bot: BotConfigBot)
}
