import discord_gleam
import gleam/io
import logging

fn main() {
  logging.configure()

  let bot = discord_gleam.bot("YOUR TOKEN")
  discord_gleam.run(bot, [])
}
