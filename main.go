/*
Guido.Go By Strawmelonjuice
*/
package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/bwmarrin/discordgo"
)

type botConfig struct {
	Nickname string
}

type GuidoConfiguration struct {
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
	configuration := GuidoConfiguration{}

	err := decoder.Decode(&configuration)
	if err != nil {
		fmt.Println("error:", err)
	}

	if exauthto == configuration.Token {
		consoleError.Fatal("Please set your Discord auth Token in the '" + configFileLocation + "' file.")
	}
	fmt.Println("Starting Guido...")
	discord, err := discordgo.New("Bot " + configuration.Token)
	if err != nil {
		fmt.Println("error creating Discord session,", err)
		return
	}
	// Register the messageCreate func as a callback for MessageCreate events.
	discord.AddHandler(messageCreate)

	// In this example, we only care about receiving message events.
	discord.Identify.Intents = discordgo.IntentsGuildMessages

	// Open a websocket connection to Discord and begin listening.
	err = discord.Open()
	if err != nil {
		fmt.Println("error opening connection,", err)
		return
	}

	// Wait here until CTRL-C or other term signal is received.
	fmt.Println("Guido is now running.  Press CTRL-C to exit.")
	sc := make(chan os.Signal, 1)
	signal.Notify(sc, syscall.SIGINT, syscall.SIGTERM, os.Interrupt)
	<-sc

	// Cleanly close down the Discord session.
	err = discord.Close()
	if err != nil {
		return
	}
}
