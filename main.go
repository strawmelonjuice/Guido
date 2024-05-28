package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/Goscord/goscord/goscord"
	"github.com/Goscord/goscord/goscord/discord"
	"github.com/Goscord/goscord/goscord/gateway"
	"github.com/Goscord/goscord/goscord/gateway/event"
)

var client *gateway.Session

type botConfig struct {
	Nickname string
}

type Configuration struct {
	Token         string
	Bot           botConfig
	configVersion int32
}

func main() {
	consoleLog := log.New(os.Stdout, "LOG\t", 1)
	consoleError := log.New(os.Stderr, "ERROR\t", 1)
	configFileLocation := string("./Guido.json")
	exauthto := string("~ your auth token here! ~")
	if _, err := os.Stat(configFileLocation); errors.Is(err, os.ErrNotExist) {
		consoleLog.Println("'" + configFileLocation + "' does not exist. Creating a new one!")
		if err := os.WriteFile(configFileLocation, []byte(`
{
	"configVersion": 1,
  "Token": "`+exauthto+`",
  "Bot": {
		"Nickname": "Guido"
		}
}
`), 0o666); err != nil {
			consoleError.Fatal(err)
		}
		os.Exit(1)
	}

	file, configOpenError := os.Open(configFileLocation)
	defer func(file *os.File) {
		fileCloseError := file.Close()
		if fileCloseError != nil {
			consoleError.Fatal("Error while loading config file: ", fileCloseError)
		}
	}(file)
	if configOpenError != nil {
		fmt.Println("error:", configOpenError)
	}
	decoder := json.NewDecoder(file)
	configuration := Configuration{}

	err := decoder.Decode(&configuration)
	if err != nil {
		fmt.Println("error:", err)
	}

	if exauthto == configuration.Token {
		consoleError.Fatal("Please set your Discord auth Token in the '" + configFileLocation + "' file.")
	}
	fmt.Println("Starting Guido...")

	client := goscord.New(&gateway.Options{
		Token:   configuration.Token,
		Intents: gateway.IntentGuildMessages,
	})

	_ = client.On(event.EventReady, func() {
		fmt.Println("Logged in as " + client.Me().Tag())
	})

	_ = client.On(event.EventMessageCreate, func(msg *discord.Message) {
		if msg.Content == "ping" {
			message, _ := client.Channel.SendMessage(msg.ChannelId, "Pong ! 🏓")
			consoleLog.Println("Send message: ", message)
		}
	})

	if client.Login() != nil {
		consoleError.Fatal("Guido could not log in to Discord. Are you sure your Token is correct?")
	}

	select {}
}
