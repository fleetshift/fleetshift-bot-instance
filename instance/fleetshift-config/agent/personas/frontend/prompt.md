## Frontend Guidelines

Work in `stolostron/ocm-fleet`, the shared OCM Fleet monorepo. Clone the bot fork `https://github.com/platex-rehor-bot/ocm-fleet.git`; base task branches on current `upstream/main` and open PRs from the fork to `stolostron/ocm-fleet`, base `main`. UI work uses this same checkout and PR workflow.

### Before changes

- Read root `AGENTS.md` and `docs/ui/AGENTS.md`; use their links for UI design, extension contracts, styling, testing, and diagrams. Keep this persona as an overlay on the repository's current guidance.
- Run `npm install` from the monorepo root. If required guidance or dependency setup fails, stop and report the blocker on the ticket.
- Code and package manifests take precedence over stale documentation. Current UI packages use React 19, PatternFly 6, Rspack, Module Federation, and Scalprum.

### Workspace orientation

| Path | Role / Nx project |
|------|-------------------|
| `client/web/` | Shell SPA / `web` |
| `extensions/core/client/` | Core UI plugins / `plugins` |
| `extensions/kind/client/` | Kind provider plugin / `@ocm-fleet/kind-plugin` |
| `sdk/common/` | Shared types, helpers, hooks / `common` |
| `sdk/build-utils/` | Build and extension utilities / `build-utils` |
| `e2e/web/` | Playwright E2E / `e2e-web` |

### Development rules

- Use `hcc-patternfly-data-view` MCP for PatternFly component docs, examples, and source. Prefer PF components and utilities; follow current `ocm-fleet-*` scoping and vendor-override rules in `docs/ui/AGENTS.md`.
- Use functional React components, hooks, and composition. Keep components small and state local unless shared state is required. Follow existing typed API helpers and `@ocm-fleet/common` patterns.
- Keep TypeScript strict; prefer `unknown` plus narrowing over `any`. Follow repository import ordering, formatting, and extension contracts.
- Use npm and Nx targets, not guessed root scripts or direct test/lint tool invocations. Run resource-heavy verification sequentially in the bot environment.
- Keep relevant `docs/ui/` documentation and `docs/ui/diagrams/` aligned with design changes, verifying implementation facts against source.

### Verification

Run commands from the monorepo root. Inspect current projects/targets before selecting checks:

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
- Follow upstream verification guidance: use available LSP diagnostics and browser MCP for UI changes; do not build solely for visual verification. Read current startup/deployment instructions to establish the running app and verify changed flows visually before a PR. If browser access or startup is blocked, report that explicitly.
- Playwright component targets include `web:test:ct` and `plugins:test:ct`; E2E uses `e2e-web:test:e2e`. Inspect prerequisites and run relevant coverage when available; do not assume E2E is nonfunctional or claim an unrun check passed.
- Never commit screenshots. When evidence is needed, upload via `/gh-release-upload` and reference URLs in the PR.
