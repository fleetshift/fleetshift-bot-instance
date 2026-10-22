# Fleetshift Instance — Additional Instructions

## Supported Repositories

Select the repository from the ticket's canonical `repo:` label and `project-repos.json`. Apply only that repository's guidance below. The `backend` persona covers OCM Fleet backend/CLI work; the `frontend` persona covers OCM Fleet UI and Scaffolding work.

### OCM Fleet (`stolostron/ocm-fleet`)

- Clone `https://github.com/platex-rehor-bot/ocm-fleet.git` as `origin`; use `https://github.com/stolostron/ocm-fleet.git` as `upstream`.
- Start work from current `upstream/main`. Push task branches to the bot fork and open PRs against `stolostron/ocm-fleet`, base `main`.
- Backend, CLI, web UI, and plugins share this checkout and PR workflow. There is no separate UI repository.
- Read root `AGENTS.md` before changes and follow its links to relevant architecture and testing guidance. For UI work, also read `docs/ui/AGENTS.md`. If required guidance or setup is unavailable, stop and report the blocker on the ticket.
- Use npm from the monorepo root. Install workspace dependencies with `npm install`; prefer `npm exec nx` for build, test, lint, proto, and image targets. Discover current projects and targets with `npm exec nx show projects` and `npm exec nx show project <project>` rather than guessing commands. Verify prerequisites before running container-dependent targets.

### Scaffolding (`scalprum/scaffolding`)

- Clone `https://github.com/platex-rehor-bot/scaffolding.git` as `origin`; use `https://github.com/scalprum/scaffolding.git` as `upstream`. Start from current `upstream/main`, push task branches to the bot fork, and open PRs against `scalprum/scaffolding`, base `main`.
- Read root `CLAUDE.md` and the relevant package README. This npm/Nx monorepo contains core, react-core, build-utils, react-test-utils, remote-types, and examples packages; follow its own paths and dependency rules rather than OCM Fleet UI conventions.
- Match `.nvmrc` and package engines (currently Node >=26 and npm >=11.14.1) before running `npm ci` at the root. Discover projects with `npm exec nx show projects` and targets with `npm exec nx show project <project>`, then run relevant existing lint, test, typecheck, or build targets. Do not assume OCM Fleet target names or `docs/ui/` exist. If required guidance or setup is unavailable, stop and report the blocker on the ticket.

## Version Management

This instance has **nvm** (Node) and **goenv** (Go) version managers installed. Use them to match the version required by each repo.

### Node.js (nvm)

Before working on a repo with `package.json`, check its `.nvmrc` or `engines.node` field and switch if needed:

```bash
nvm use          # reads .nvmrc if present
nvm install 20   # install + switch to Node 20
nvm use default  # back to default (22)
```

Default: Node.js 22 LTS. Available globally via `/usr/local/bin/node`.

### Go (goenv)

Before working on a repo with `go.mod`, check the `go` directive and switch if needed:

```bash
goenv versions                    # list installed versions
goenv install 1.23.0              # install a new version
goenv global 1.23.0               # set as default
goenv local 1.24.2                # set for current directory only
```

Pre-installed: Go 1.24.2 (default), 1.25.7. Available globally via `/usr/local/bin/go`.

### When to switch

- `go.mod` says `go 1.23` → `goenv install 1.23.x && goenv local 1.23.x`
- `.nvmrc` says `20` → `nvm use 20` (installs automatically if missing)
- No version file → use the defaults
