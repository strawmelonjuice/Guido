import discord_gleam
import discord_gleam/event_handler
import discord_gleam/types/message
import discord_gleam/types/slash_command
import discord_gleam/ws/packets/message_delete
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import guido/types
import guido/types/config as types_config
import logging

// import glerd_gen
// import glerd_json

pub fn main() {
  // // Please keep this commented out. It ruins the generated code. Instead I copied the correct generated code from glerd_json_gen.gleam to types.gleam
  // glerd_gen.record_info
  // |> glerd_json.generate("src", _)
  io.println("HOWDY!")
  case types_config.load() {
    Ok(config) -> start(config)
    Error(e) ->
      io.println_error("Failed to load configuration: " <> string.inspect(e))
  }
}

fn start(config: types.BotConfig) {
  io.println("Guido is starting up!")
  logging.configure()
  let session = discord_gleam.bot(config.token)
  let slash_commands = []
  list.append(slash_commands, [
    slash_command.SlashCommand(
      name: "test",
      type_: 1,
      description: "test command",
      options: [],
    ),
  ])
  list.append(slash_commands, [
    slash_command.SlashCommand(
      name: "ping",
      type_: 1,
      description: "returns pong",
      options: [],
    ),
  ])
  list.append(slash_commands, [
    slash_command.SlashCommand(
      name: "pong",
      type_: 1,
      description: "returns ping",
      options: [],
    ),
  ])
  discord_gleam.register_commands(
    session,
    int.to_string(config.bot_id),
    slash_commands,
  )
  discord_gleam.run(session, [event_handler])
}

fn event_handler(bot, packet: event_handler.Packet) {
  case packet {
    event_handler.ReadyPacket(ready) -> {
      logging.log(logging.Info, "Logged in as " <> ready.d.user.username)
      discord_gleam.send_message(bot, "1245310854027673614", "I'm online!", [
        message.Embed(
          title: "Guido is online!",
          description: "Woohoo!",
          color: 0x00FF00,
        ),
      ])
      Nil
    }
    event_handler.MessagePacket(message) -> {
      logging.log(logging.Info, "Message: " <> message.d.content)
      case message.d.content {
        "!embed" -> {
          let embed1 =
            message.Embed(
              title: "Embed Title",
              description: "Embed Description",
              color: 0x00FF00,
            )

          discord_gleam.send_message(bot, message.d.channel_id, "Embed!", [
            embed1,
          ])
        }
        _ -> Nil
      }
    }
    event_handler.InteractionCreate(interaction) -> {
      logging.log(logging.Info, "Interaction: " <> interaction.d.data.name)

      case interaction.d.data.name {
        "ping" -> {
          discord_gleam.interaction_reply_message(interaction, "pong")

          Nil
        }
        "pong" -> {
          discord_gleam.interaction_reply_message(interaction, "ping")

          Nil
        }
        _ -> Nil
      }
    }
    _ -> Nil
  }
}
