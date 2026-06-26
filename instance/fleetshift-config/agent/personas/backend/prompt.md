## Backend Guidelines

FleetShift management-plane — Go monorepo. gRPC + grpc-gateway HTTP transcoding. Protobuf (buf). Two modules: `fleetshift-server` (main), `fleetshift-cli` (`fleetctl`).

### Before changes

Read `AGENTS.md` at repo root — it links to architecture docs and internal design docs that contain rules easy to violate without context. Fails → STOP, Jira comment, don't proceed.

### Repo layout

| Dir | What |
|-----|------|
| `fleetshift-server/` | Management plane server. All server code under `internal/`. |
| `fleetshift-cli/` | CLI binary (`fleetctl`). `replace` directive → `../fleetshift-server`. |
| `proto/fleetshift/v1/` | Protobuf definitions (~45 `.proto`). Buf v2. |
| `deploy/` | `podman/`, `kubernetes/`, `keycloak/` configs. |
| `poc/` | Proof-of-concept experiments (attestation, gcp-hcp, ocm adapter). |
| `docs/` | Design docs, API design, OpenAPI output. |

### Server internals (`fleetshift-server/internal/`)

| Pkg | What |
|-----|------|
| `domain/` | Aggregates, entities, values, repo interfaces. `*repotest/` = contract tests. |
| `application/` | Service layer — orchestrates domain, repos, workflows. |
| `infrastructure/` | Implementations: `sqlite/`, `postgres/`, `oidc/`, `delivery/`, `goworkflows/`, `keyregistry/`. |
| `transport/` | `grpc/`, `http/` — handlers, middleware. |
| `addon/` | Addon plugins: `kind/`, `gcphcp/`, `kubernetes/`. |
| `testserver/` | In-process gRPC test server (SQLite in-mem + stub OIDC). |
| `testutil/` | Shared test helpers. |
| `gen/fleetshift/v1/` | Generated proto Go code. **Never edit.** |

### Task lifecycle — cookbook

**1. Orient**
```
read ticket → WHAT + WHY
read relevant docs/ (see AGENTS.md "For how to..." list)
grep existing patterns → match, don't invent
```

**2. TDD — write failing test first**
```bash
cd fleetshift-server
go test ./internal/path/to/pkg/ -run TestYourThing -count=1
```
Contract tests → `domain/*repotest/`. New repo interface? Add contract tests.
Integration test → `testserver/testserver.go` (full in-process gRPC, SQLite in-mem).

**3. Implement**
- Domain logic → `internal/domain/`
- Service orchestration → `internal/application/`
- Storage → `internal/infrastructure/sqlite/` or `postgres/`
- Transport → `internal/transport/grpc/` or `http/`
- Addons → `internal/addon/<name>/`
- Proto → edit `proto/fleetshift/v1/*.proto` → `task protogen`

**4. Verify**
```bash
# Format — always
go fmt ./...

# Unit + contract tests — always
cd fleetshift-server && go test -count=1 ./...

# Integration tests — when touching addon/kind or Docker code
go test -tags integration -count=1 ./internal/addon/kind/

# Proto lint — when touching .proto
buf lint

# Build smoke
task build:server
```

**5. Commit**
- Conventional: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Scope = package: `feat(delivery):`, `fix(sqlite):`
- Tests + impl together, one logical change per commit.

### Don'ts

- No mocks. Real instances or in-mem fakes. Contract tests validate interfaces.
- No `time.Sleep` in tests. Clock injection or `synctest`.
- No `docker` CLI. Use `podman`. Images: `task image:build`.
- No removing comments unless truly dead. Update > delete.
- No editing `internal/gen/`. Edit `.proto` → `task protogen`.
- No `golangci-lint` — not configured. `go fmt` + `go vet` suffice.
- No `make`. Use `task` (Taskfile). `task -l` for targets.

### Key conventions

- **AIP-aligned APIs** — see `docs/api-design.md`, `docs/buf.md`.
- **Layering** — domain has no infra imports. Application orchestrates. Transport is thin.
- **Observer pattern** for instrumentation — see `fleetshift-server/docs/observer-pattern.md`.
- **Constructors** — see `fleetshift-server/docs/constructors.md`. Don't invent new patterns.
- **Durable workflows** — see `fleetshift-server/docs/durable-workflows.md`. `goworkflows/` + `memworkflow/` (test).
- **Modern stdlib** — prefer stdlib crypto, encoding, net/http over third-party.

### Commands

```bash
task build:all         # server + CLI
task build:server      # server only
task protogen          # buf generate (skips if unchanged)
task image:build       # podman build
task -l                # list all targets
go test -count=1 ./... # unit + contract (from fleetshift-server/)
go test -tags integration ./internal/addon/kind/  # Docker-heavy
buf lint               # proto lint
go fmt ./...           # format
```
