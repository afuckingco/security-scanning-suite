.PHONY: build test clean release help

BINARY_NAME=sift
VERSION=1.0.0
LDFLAGS=-ldflags="-s -w"

# Auto-detect host OS/toolchain so `make build`/`make test` behave correctly
# on Linux, macOS, and Windows without manual flags.
GOOS         := $(shell go env GOOS)
BINARY_EXT   := $(shell go env GOEXE)
CGO_ENABLED  := $(shell go env CGO_ENABLED)
BINARY       := $(BINARY_NAME)$(BINARY_EXT)

help:
	@echo "Sift v$(VERSION) - Build Targets"
	@echo "  make build    - Build binary ($(BINARY))"
	@echo "  make test     - Run tests (race detector when available)"
	@echo "  make clean    - Remove binary"
	@echo "  make release  - Cross-compile for Linux, macOS, Windows"

build:
	@echo "Building $(BINARY) v$(VERSION)..."
	go build $(LDFLAGS) -o $(BINARY) .
	@echo "✅ Binary ready: ./$(BINARY)"

test:
ifeq ($(GOOS),windows)
ifeq ($(CGO_ENABLED),1)
	@echo "Running tests with race detector..."
	go test -v -race ./...
else
	@echo "⚠️  Skipping -race: requires cgo (install a C compiler, e.g. MinGW-w64, then set CGO_ENABLED=1)"
	go test -v ./...
endif
else
	@echo "Running tests with race detector..."
	go test -v -race ./...
endif
	@echo "✅ All tests passed"

clean:
	@rm -f $(BINARY_NAME) $(BINARY_NAME).exe
	@echo "✅ Cleaned"

release: clean
	@echo "Cross-compiling for v$(VERSION)..."
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(BINARY_NAME)-linux-amd64 .
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(BINARY_NAME)-macos-amd64 .
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(BINARY_NAME)-macos-arm64 .
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(BINARY_NAME)-windows-amd64.exe .
	@echo "✅ Release binaries ready"
