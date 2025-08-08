# kbot

A Telegram bot.

## Installation

1. Clone the repository:
```bash
git clone https://github.com/nasgul/kbot.git
cd kbot
```

2. Set up your Telegram Bot Token:
```bash
export TELE_TOKEN="your_telegram_bot_token"
```

3. Build the application:
```bash
go build -ldflags "-X="github.com/nasgul/kbot/cmd.appVersion=v1.0.2
```

## Usage

Start the bot:
```bash
./kbot start
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
