## Backend Guidelines

Work in `stolostron/ocm-fleet`, the shared OCM Fleet monorepo. Clone the bot fork `https://github.com/platex-rehor-bot/ocm-fleet.git`; base task branches on current `upstream/main` and open PRs from the fork to `stolostron/ocm-fleet`, base `main`.

### Before changes

- Read root `AGENTS.md` and its relevant architecture/API guidance under `docs/design/` and `docs/`.
- For server changes, read the relevant `server/docs/` guides linked from root: internal architecture, package structure, testing, domain, constructors, observability, and durable workflows. Follow existing layering and patterns rather than duplicating architecture rules here.
- The Go resource manager lives in `server/`; the TypeScript CLI lives in `client/cli/`. Protobuf sources are under `proto/`. Consult `client/cli/AGENTS.md` for CLI work and `docs/buf.md` for protobuf changes.
- If required guidance or dependency setup fails, stop and report the blocker on the ticket.

### Implementation and tests

- Follow upstream TDD guidance: capture bugs with a failing test before fixing them; cover edge cases.
- Follow `server/docs/testing.md`: prefer real instances or reusable in-memory fakes, add interface contract tests for alternate implementations, and avoid method-verifying mocks. Use injected clocks or deterministic concurrency instead of `time.Sleep`.
- Edit protobuf sources and regenerate through Nx; do not hand-edit generated code. Follow upstream API design and layer boundaries.
- Format Go changes with `go fmt ./...` from the affected Go module (`server/` for resource manager changes). For focused server test iteration, run `go test ./...` from `server/`, narrowing to the affected package as needed.
- Default server tests exclude integration-tagged Docker-heavy tests. Container-dependent tests need a working runtime and other prerequisites; check availability and report skipped checks with reasons instead of claiming they passed.
- Preserve useful comments, update relevant design docs when the design changes, and prefer modern standard-library abstractions where appropriate.

### Commands

Run workspace commands from the monorepo root after `npm install`. Prefer Nx for dependency-aware verification:

```bash
npm exec nx show projects
npm exec nx show project server
npm exec nx run server:build
npm exec nx run server:test
npm exec nx run cli:build
npm exec nx run cli:test
npm exec nx run cli:lint
npm exec nx run proto:generate
```

Choose checks for the changed code. `server:test-integration` is the explicit Nx target for server integration coverage; inspect its current definition and prerequisites before running it. Discover any additional lint, proto, image, or deployment targets from the current workspace instead of assuming scripts exist.

### Commits and PRs

- Conventional commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`); use a relevant scope when helpful.
- Keep tests and implementation together in logical commits. Include actual verification results and any blocked checks in the PR.
