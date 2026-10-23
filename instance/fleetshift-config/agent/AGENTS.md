# Fleetshift Instance — Additional Instructions

## Native Subagents

`opencode.json` selects `fleetshift-coordinator` as default primary agent, limits delegation depth to one, and grants it access only to `backend` and `frontend`. These are actual native subagents in `.opencode/agents/`, not instruction snippets. When workflow asks to load/reload `personas/<name>/prompt.md`, select and invoke matching native subagent instead of reading legacy persona paths.

- Invoke `backend` only for scoped OCM Fleet backend/CLI/protobuf implementation.
- Invoke `frontend` for scoped OCM Fleet UI or Scaffolding implementation, using only its matching repository section.
- For OCM Fleet full-stack work, delegate sequentially when workers share checkout; avoid concurrent writers.
- Coordinator owns Jira/task lifecycle, status, integration, review, commit/push, PR lifecycle, and cycle completion. Workers implement assigned scope, return evidence, and cannot recursively delegate.
- Subagents share runner filesystem and inherited tools. Their role permissions do not provide separate OS sandboxes. Keep every brief inside approved repository/workspace boundaries and inspect changes before acting.
- Current target-repository instructions take precedence over instance role guidance. Backend checkout rules never apply to Scaffolding.

### Jira Claim Fallback

Coordinator attempts normal Jira claim once. If issue is readable and already selected/authorized for work, but assignment, transition, or sprint claim operation fails due to temporary Jira tool or permission issues, proceed with implementation without repeated claim attempts. Leave Jira assignment, status, and sprint unchanged; do not claim success or write fake progress. Include exact failure in final report and PR update. Stop only if issue access, eligibility, or authorization is unclear, conflicting ownership exists, or implementation requires unavailable Jira permission. This fallback covers claim bookkeeping only; it does not bypass task authorization. Workers never claim or modify Jira state.

Use `/home/botuser/repos` for project checkouts, `/home/botuser/data` for persistent task data, and `/tmp/opencode` for task scratch files. These are the deployment-approved external roots; the runner workspace is `/home/botuser/app`.

## Native Runtime Verification Override

OpenCode 2.1.2 has no LSP runtime or tools. This overrides workflow and persona directives to use LSP, including LSP diagnostics before a commit: use the current repository's existing lint, typecheck, compiler, and test targets for diagnostics and verification, and report the commands actually run and their results. Do not claim LSP diagnostics were performed.

The `browser` environment is not selected for this instance. For UI work, use browser/visual verification tools only if available; otherwise report the missing tooling and visual-verification gaps explicitly. Do not claim unavailable visual checks passed.

## Supported Repositories

Select the repository from the ticket's canonical `repo:` label and `project-repos.json`. Apply only that repository's guidance below. The `backend` subagent covers OCM Fleet backend/CLI work; the `frontend` subagent covers OCM Fleet UI and Scaffolding work.

### OCM Fleet (`stolostron/ocm-fleet`)

- Clone `https://github.com/platex-rehor-bot/ocm-fleet.git` as `origin`; use `https://github.com/stolostron/ocm-fleet.git` as `upstream`.
- Start work from current `upstream/main`. Push task branches to the bot fork and open PRs against `stolostron/ocm-fleet`, base `main`.
- Backend, CLI, web UI, and plugins share this checkout and PR workflow. There is no separate UI repository.
- Read root `AGENTS.md` before changes and follow its links to relevant architecture and testing guidance. For UI work, also read `docs/ui/AGENTS.md`. Stop and report if required guidance or task authorization is unavailable; optional verification setup being unavailable does not block implementation. Run available checks and report skipped checks accurately.
- Use npm from the monorepo root. Install workspace dependencies with `npm install`; prefer `npm exec nx` for build, test, lint, proto, and image targets. Discover current projects and targets with `npm exec nx show projects` and `npm exec nx show project <project>` rather than guessing commands. Verify prerequisites before running container-dependent targets.

### Scaffolding (`scalprum/scaffolding`)

- Clone `https://github.com/platex-rehor-bot/scaffolding.git` as `origin`; use `https://github.com/scalprum/scaffolding.git` as `upstream`. Start from current `upstream/main`, push task branches to the bot fork, and open PRs against `scalprum/scaffolding`, base `main`.
- Read root `CLAUDE.md` and the relevant package README. This npm/Nx monorepo contains core, react-core, build-utils, react-test-utils, remote-types, and examples packages; follow its own paths and dependency rules rather than OCM Fleet UI conventions.
- Prefer `.nvmrc` and package `engines` (currently Node >=26 and npm >=11.14.1). Attempt version-manager installation/use once; if unavailable, use the closest installed Node version and continue. Do not change `.nvmrc`, project engine declarations, package manifests, lockfiles, or npm config. Run `npm ci` at the root. If it fails and engine validation is the sole failure, one retry may use `npm_config_engine_strict=false npm ci`; make no persistent config change. If installation still fails, continue implementation and run checks that work. Discover projects with `npm exec nx show projects` and targets with `npm exec nx show project <project>`, then run relevant existing lint, test, typecheck, or build targets. Do not assume OCM Fleet target names or `docs/ui/` exist. Report actual Node/npm versions, any one-command override, skipped checks and reasons, and compatibility uncertainty. Never report skipped checks as passed.

## Version Management

This instance has **nvm** (Node) and **goenv** (Go) version managers installed. Use them to match the version required by each repo.

### Node.js (nvm)

Before working on a repo with `package.json`, prefer its `.nvmrc` or `engines.node` field and attempt version-manager installation/use once:

```bash
nvm use          # reads .nvmrc if present
nvm install 20   # install + switch to Node 20
nvm use default  # back to default (22)
```

If required version cannot be installed or used, choose closest installed Node version and continue implementation. Do not change repository runtime declarations or package/npm configuration. Report actual version and compatibility uncertainty; run available checks and accurately report skips. Default: Node.js 22 LTS. Available globally via `/usr/local/bin/node`.

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
