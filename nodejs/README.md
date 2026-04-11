# Makefiles for Node.js projects

This Makefile provides a standard set of targets for Node.js / TypeScript projects
using npm (swap `PKG_MANAGER` for `yarn` or `pnpm` as needed).

## Usage

```shell
make install       # npm ci (cached via stamp file)
make build         # npm run build
make test          # npm run test
make lint          # npm run lint
make fmt           # npm run format
make type-check    # tsc --noEmit
make clean         # remove dist/ and node_modules/
make ci            # full CI pipeline
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PKG_MANAGER` | `npm` | Package manager (`npm`, `yarn`, `pnpm`) |
| `INSTALL_CMD` | `npm ci` | Install command |
| `BUILD_DIR` | `dist` | Build output directory |
