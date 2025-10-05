# Automatic platform detection
ifeq '$(findstring ;,$(PATH))' ';'
	detected_OS := windows
	detected_arch := amd64
else
	detected_OS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
	detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
	detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
	detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
	detected_arch := $(shell dpkg --print-architecture 2>/dev/null || uname -m | sed 's/x86_64/amd64/' 2>/dev/null || echo amd64)
endif

# Colors for beautiful output
B = \033[1;94m# BLUE
G = \033[1;92m# GREEN
Y = \033[1;93m# YELLOW
R = \033[1;31m# RED
M = \033[1;95m# MAGENTA
K = \033[K#    ERASE END OF LINE
D = \033[0m#   DEFAULT
A = \007#      BEEP

# Main variables
APP = $(shell basename $(shell git remote get-url origin) .git)
REGISTRY = ghcr.io/nasgul
VERSION = $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.1.0)
TELE_TOKEN = 111

# Default parameters (can be overridden)
TARGETOS ?= $(detected_OS)
TARGETARCH ?= $(detected_arch)

.PHONY: help format lint get test build clean image push dive
.DEFAULT_GOAL := help

# Show available commands
help:
	@printf "$B═══════════════════════════════════════════════════════════════$D\n"
	@printf "$B  🚀 $(APP) Build System$D\n"
	@printf "$B═══════════════════════════════════════════════════════════════$D\n"
	@printf "$G📋 Development:$D\n"
	@printf "  $Yformat$D     - Format Go code with gofmt\n"
	@printf "  $Ylint$D       - Run linting with go vet\n"
	@printf "  $Yget$D        - Download Go dependencies\n"
	@printf "  $Ytest$D       - Run tests with verbose output\n"
	@printf "$G🔧 Build:$D\n"
	@printf "  $Ybuild$D      - Build for current platform ($(detected_OS)/$(detected_arch))\n"
	@printf "  $Ylinux$D      - Build for Linux\n"
	@printf "  $Ydarwin$D     - Build for macOS\n"
	@printf "  $Ywindows$D    - Build for Windows\n"
	@printf "  $Yarm$D        - Build for ARM architecture\n"
	@printf "$G🐳 Docker:$D\n"
	@printf "  $Yimage$D      - Build Docker image\n"
	@printf "  $Ypush$D       - Push image to registry\n"
	@printf "  $Ydive$D       - Analyze Docker image efficiency\n"
	@printf "$G🧹 Utility:$D\n"
	@printf "  $Yclean$D      - Clean build artifacts and images\n"
	@printf "$B═══════════════════════════════════════════════════════════════$D\n"

# Development tasks
format:
	@printf "$G📝 Formatting Go code...$D\n"
	@gofmt -s -w ./ && printf "$G✅ Code formatted successfully$D\n" || printf "$R❌ Format failed$D\n"

lint:
	@printf "$G🔍 Running linter...$D\n"
	@go vet ./... && printf "$G✅ Linting passed$D\n" || printf "$R❌ Linting failed$D\n"

get:
	@printf "$G📦 Getting dependencies...$D\n"
	@go get && printf "$G✅ Dependencies updated$D\n" || printf "$R❌ Failed to get dependencies$D\n"

test:
	@printf "$G🧪 Running tests...$D\n"
	@go test -v && printf "$G✅ All tests passed$D\n" || printf "$R❌ Tests failed$D\n"

# Basic build
build: format get
	@printf "$G🔨 Building $(APP)...$D\n"
	@printf "$G   Target: $Y$(TARGETOS)/$(TARGETARCH)$D\n"
	@printf "$G   Version: $Y$(VERSION)$D\n"
	@CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build \
		-v -o kbot \
		-ldflags "-X=github.com/nasgul/kbot/cmd.appVersion=$(VERSION)" \
		&& printf "$G✅ Build completed: $Ykbot$D\n" \
		|| printf "$R❌ Build failed$D\n"

# Platform-specific builds
linux: 
	@$(MAKE) build TARGETOS=linux TARGETARCH=$(detected_arch)

darwin:
	@$(MAKE) build TARGETOS=darwin TARGETARCH=$(detected_arch)

darwin_arm64:
	@$(MAKE) build TARGETOS=darwin TARGETARCH=arm64

windows:
	@$(MAKE) build TARGETOS=windows TARGETARCH=$(detected_arch)

arm:
	@$(MAKE) build TARGETOS=$(detected_OS) TARGETARCH=arm

arm64:
	@$(MAKE) build TARGETOS=$(detected_OS) TARGETARCH=arm64

image: build
	@printf "$G🐳 Building Docker image...$D\n"
	@printf "$G   Registry: $Y$(REGISTRY)$D\n"
	@printf "$G   Tag: $Y$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)$D\n"
	@if [ "$(TARGETOS)" = "linux" ]; then \
		DOCKER_BUILDKIT=1 docker build \
			--no-cache \
			--build-arg TARGETOS=$(TARGETOS) \
			--build-arg TARGETARCH=$(TARGETARCH) \
			--secret id=tele_token,env=TELE_TOKEN \
			-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) . \
			&& printf "$G✅ Docker image built successfully$D\n" \
			|| printf "$R❌ Docker build failed$D\n"; \
	else \
		DOCKER_BUILDKIT=1 docker build \
			--build-arg TARGETOS=$(TARGETOS) \
			--build-arg TARGETARCH=$(TARGETARCH) \
			-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) . \
			&& printf "$G✅ Docker image built successfully$D\n" \
			|| printf "$R❌ Docker build failed$D\n"; \
	fi

image_all:
	@printf "$G🐳 Building images for all platforms...$D\n"
	@$(MAKE) image TARGETOS=linux TARGETARCH=amd64
	@$(MAKE) image TARGETOS=linux TARGETARCH=arm64
	@$(MAKE) image TARGETOS=darwin TARGETARCH=amd64
	@$(MAKE) image TARGETOS=darwin TARGETARCH=arm64
	@$(MAKE) image TARGETOS=windows TARGETARCH=amd64

push:
	@printf "$G🚀 Pushing image to registry...$D\n"
	@docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) \
		&& printf "$G✅ Image pushed successfully$D\n" \
		|| printf "$R❌ Push failed$D\n"

push_all:
	@printf "$G🚀 Pushing all platform images...$D\n"
	@docker push $(REGISTRY)/$(APP):$(VERSION)-linux-amd64
	@docker push $(REGISTRY)/$(APP):$(VERSION)-linux-arm64
	@docker push $(REGISTRY)/$(APP):$(VERSION)-darwin-amd64
	@docker push $(REGISTRY)/$(APP):$(VERSION)-darwin-arm64
	@docker push $(REGISTRY)/$(APP):$(VERSION)-windows-amd64

dive: image
	@printf "$G🔍 Analyzing Docker image efficiency...$D\n"
	@IMG1=$$(docker images -q $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) | head -n 1); \
	if [ -n "$$IMG1" ]; then \
		CI=true docker run -ti --rm \
			-v /var/run/docker.sock:/var/run/docker.sock \
			wagoodman/dive --ci --lowestEfficiency=0.99 $$IMG1; \
	else \
		printf "$R❌ Image not found for analysis$D\n"; \
	fi

info:
	@printf "$B═══════════════════════════════════════════════════════════════$D\n"
	@printf "$B  📊 System Information$D\n"
	@printf "$B═══════════════════════════════════════════════════════════════$D\n"
	@printf "$G🖥️  Detected OS/Arch:$D $(detected_OS)/$(detected_arch)\n"
	@printf "$G🎯 Target OS/Arch:$D $(TARGETOS)/$(TARGETARCH)\n"
	@printf "$G📱 App Name:$D $(APP)\n"
	@printf "$G🏷️  Version:$D $(VERSION)\n"
	@printf "$G🐳 Registry:$D $(REGISTRY)\n"
	@printf "$G🔑 Telegram Token:$D $(TELE_TOKEN)\n"
	@printf "$B═══════════════════════════════════════════════════════════════$D\n"

clean:
	@printf "$G🧹 Cleaning up...$D\n"
	@rm -f kbot && printf "$G✅ Binary removed$D\n" || printf "$Y⚠️  No binary to remove$D\n"
	@if [ "$$(docker images -q $(REGISTRY)/$(APP) 2>/dev/null)" ]; then \
		docker images $(REGISTRY)/$(APP) --format "{{.ID}}" | xargs docker rmi -f \
		&& printf "$G✅ Docker images removed$D\n"; \
	else \
		printf "$Y⚠️  No images to remove$D\n"; \
	fi

clean_all: clean
	@printf "$G🧹 Deep cleaning...$D\n"
	@go clean -cache -modcache -testcache && printf "$G✅ Go caches cleared$D\n"
	@docker system prune -f && printf "$G✅ Docker system cleaned$D\n"

ci_test: format lint test
	@printf "$G✅ CI tests completed successfully$D\n"

ci_build: ci_test build
	@printf "$G✅ CI build completed successfully$D\n"

ci_deploy: ci_build image push
	@printf "$G✅ CI deployment completed successfully$D\n"