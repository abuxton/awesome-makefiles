# Makefiles for Go projects

This Makefile provides a standard set of targets for Go modules with cross-compilation support.

## Usage

```shell
make build         # build release binary → bin/
make build-debug   # build with race detector
make build-all     # cross-compile for all platforms
make test          # go test ./... with coverage
make lint          # golangci-lint run
make fmt           # go fmt ./...
make vet           # go vet ./...
make deps          # go mod download
make tidy          # go mod tidy && verify
make clean         # remove bin/ and coverage.out
make ci            # full CI pipeline
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BINARY` | directory name | Output binary name |
| `BUILD_DIR` | `bin` | Build output directory |
| `GO` | `go` | Go toolchain binary |
| `PLATFORMS` | `linux/amd64 linux/arm64 darwin/amd64 darwin/arm64` | Cross-compile targets |
| `VERSION` | `git describe` | Version string embedded via ldflags |
