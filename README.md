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


### **Makefile Description** 🛠️

This Makefile simplifies the process of building, testing, and managing Docker images for the **kbot** application across multiple platforms.

#### **Variables**

  * `APP`: The application name, automatically determined from the Git remote URL.
  * `REGISTRY`: The Docker image registry, set to `ghcr.io/nasgul`.
  * `VERSION`: The version string, based on the latest Git tag and commit hash.

#### **Core Targets**
# 🚀 Makefile Build System

A comprehensive, cross-platform Makefile for Go projects with automatic platform detection, Docker integration, and beautiful colored output.

## 📚 Available Commands

### Development Tasks

| Command | Description |
|---------|-------------|
| `make format` | Format Go code with `gofmt` |
| `make lint` | Run linting with `go vet` |
| `make get` | Download Go dependencies |
| `make test` | Run tests with verbose output |

### Build Tasks

| Command | Description |
|---------|-------------|
| `make build` | Build for current platform (auto-detected) |
| `make linux` | Build for Linux |
| `make darwin` | Build for macOS |
| `make darwin_arm64` | Build for macOS ARM64 |
| `make windows` | Build for Windows |
| `make arm` | Build for ARM architecture |
| `make arm64` | Build for ARM64 architecture |

### Docker Tasks

| Command | Description |
|---------|-------------|
| `make image` | Build Docker image for current platform |
| `make image_all` | Build images for all platforms |
| `make push` | Push current platform image to registry |
| `make push_all` | Push all platform images to registry |
| `make dive` | Analyze Docker image efficiency |

### Utility Tasks

| Command | Description |
|---------|-------------|
| `make info` | Show system and build information |
| `make clean` | Clean build artifacts and Docker images |
| `make clean_all` | Deep clean including Go caches |

### CI/CD Tasks

| Command | Description |
|---------|-------------|
| `make ci_test` | Run all tests (format + lint + test) |
| `make ci_build` | Complete build pipeline |
| `make ci_deploy` | Full deployment pipeline |


## 📊 Platform Support

### Automatic Detection

The Makefile automatically detects your platform:

- **Windows**: Detected by semicolon in PATH
- **Linux/macOS/Unix**: Detected using `uname`
- **Architecture**: Uses `dpkg` on Debian/Ubuntu, falls back to `uname -m`

### Supported Platforms

| OS | Architecture | Status |
|----|--------------|--------|
| Linux | amd64 | ✅ Full support |
| Linux | arm64 | ✅ Full support |
| macOS | amd64 | ✅ Full support |
| macOS | arm64 | ✅ Full support |
| Windows | amd64 | ✅ Full support |
| Any | arm | ✅ Full support |

## 🔗 Related Tools

- **Go**: https://golang.org/
- **Docker**: https://docker.com/
- **Docker BuildKit**: https://docs.docker.com/develop/dev-best-practices/
- **Dive**: https://github.com/wagoodman/dive
- **GNU Make**: https://www.gnu.org/software/make/


## License

This project is licensed under the MIT License - see the LICENSE file for details.
