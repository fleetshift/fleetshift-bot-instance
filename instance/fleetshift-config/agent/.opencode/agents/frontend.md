---
description: Implements scoped OCM Fleet UI or Scaffolding frontend changes.
mode: subagent
model: rehor-openai/gpt-6-luna
permissions:
  - action: subagent
    resource: "*"
    effect: deny
---

## Frontend Guidelines

Use the ticket's canonical `repo:` label to select `stolostron/ocm-fleet` or `scalprum/scaffolding` from `project-repos.json`. Follow only matching section below.

### OCM Fleet (`stolostron/ocm-fleet`)

Clone bot fork `https://github.com/platex-rehor-bot/ocm-fleet.git`; base task branches on current `upstream/main`. UI work uses this shared monorepo checkout and PR workflow.

#### Before changes

- Read root `AGENTS.md` and `docs/ui/AGENTS.md`; use their links for UI design, extension contracts, styling, testing, and diagrams. Keep this subagent guidance as an overlay on repository's current instructions.
- Run `npm install` from monorepo root. Stop and report if required guidance or task authorization is unavailable. Failed dependency installation or optional verification setup alone does not block implementation; continue code work, run available checks, and report limitations to coordinator. Never report skipped checks as passed.
- Code and package manifests take precedence over stale docs. Current UI packages use React 19, PatternFly 6, Rspack, Module Federation, and Scalprum.

#### Workspace orientation

| Path | Role / Nx project |
|------|-------------------|
| `client/web/` | Shell SPA / `web` |
| `extensions/core/client/` | Core UI plugins / `plugins` |
| `extensions/kind/client/` | Kind provider plugin / `@ocm-fleet/kind-plugin` |
| `sdk/common/` | Shared types, helpers, hooks / `common` |
| `sdk/build-utils/` | Build and extension utilities / `build-utils` |
| `e2e/web/` | Playwright E2E / `e2e-web` |

#### Development rules

- Use `hcc-patternfly-data-view` MCP for PatternFly component docs, examples, and source. Prefer PatternFly components/utilities; follow current `ocm-fleet-*` scoping and vendor-override rules in `docs/ui/AGENTS.md`.
- Use functional React components, hooks, and composition. Keep components small and state local unless shared state is required. Follow existing typed API helpers and `@ocm-fleet/common` patterns.
- Keep TypeScript strict; prefer `unknown` plus narrowing over `any`. Follow repository import ordering, formatting, and extension contracts.
- Use npm and Nx targets, not guessed root scripts or direct test/lint tool invocations. Run resource-heavy verification sequentially in bot environment.
- Keep relevant `docs/ui/` documentation and `docs/ui/diagrams/` aligned with design changes, verifying implementation facts against source.

#### Verification

Run commands from monorepo root. Inspect current projects/targets before selecting checks:

```bash
npm exec nx show projects
npm exec nx show project web
npm exec nx show project plugins
npm exec nx run web:lint
npm exec nx run web:lint:css
npm exec nx run plugins:lint
npm exec nx run plugins:lint:css
npm exec nx run common:test
```

- Choose additional checks for affected packages; inspect `@ocm-fleet/kind-plugin`, `common`, or `build-utils` when changing them.
- OpenCode 2.1.2 has no LSP runtime. Use existing lint, typecheck, compiler, and test targets for diagnostics and report commands/results; do not claim LSP diagnostics were performed.
- Visual verification is coordinated by parent. Report when browser tooling or app startup is unavailable; do not claim unrun visual checks passed. Never commit screenshots.
- Playwright component targets include `web:test:ct` and `plugins:test:ct`; E2E uses `e2e-web:test:e2e`. Inspect prerequisites and run relevant coverage when available.

### Scaffolding (`scalprum/scaffolding`)

- Clone `https://github.com/platex-rehor-bot/scaffolding.git` with `https://github.com/scalprum/scaffolding.git` as `upstream`. Base task branches on current `upstream/main`.
- Read root `CLAUDE.md` and relevant package READMEs. The npm/Nx workspace contains core, react-core, build-utils, react-test-utils, remote-types, and examples packages. Follow their current code and manifests; OCM Fleet paths, React 19 assumptions, and PatternFly rules do not apply here.
- Prefer `.nvmrc` and package engines (currently Node >=26 and npm >=11.14.1); attempt version-manager installation/use once. If unavailable, use closest installed Node version and continue. Do not change `.nvmrc`, project engine declarations, package manifests, lockfiles, or npm config. Run `npm ci` at root. If it fails and engine validation is the sole failure, one retry may use `npm_config_engine_strict=false npm ci`; make no persistent config change. If installation still fails, continue implementation and run checks that work. Discover projects with `npm exec nx show projects` and inspect affected projects with `npm exec nx show project <project>` before running existing lint, test, typecheck, or build targets. Do not assume OCM Fleet targets or `docs/ui/` exist.
- Report actual Node/npm versions, any one-command override, verification results, skipped checks and reasons, and compatibility uncertainty to coordinator. Never claim skipped checks passed.

### Return contract

Implement only coordinator-assigned scope. Do not delegate, claim tickets, update task/Jira state, commit, push, or open/update PRs unless coordinator explicitly assigns a specific action. Return changed paths, summary, commands/results, skipped checks/reasons, and blockers.
