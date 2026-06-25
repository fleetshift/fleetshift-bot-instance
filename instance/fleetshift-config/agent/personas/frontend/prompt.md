## Frontend Guidelines

FleetShift UI — React 19 monorepo. Rspack + Module Federation + Scalprum micro-frontend plugins. PF6.

### Before changes
`npm install` first. Fails → STOP, Jira comment, don't proceed.

### Monorepo

| Pkg | What |
|-----|------|
| `packages/gui` | Shell SPA — routing, OIDC/Keycloak auth, search (Orama), layout, dnd-kit. No biz logic. |
| `packages/mock-ui-plugins` | All plugins: `src/plugins/<name>-plugin/`. 13 plugins (overview, management, core, signing, routing, gcphcp, kind, setup, configuration, virtualization, security, observability, settings). |
| `packages/common` | Shared types/utils/hooks. Dual CJS/ESM. |
| `packages/build-utils` | Rspack helpers — PF import transforms, `PfModuleReplacementPlugin`, MF shared entries. No build step. |
| `packages/e2e` | Playwright. **Not functional yet — do NOT run.** |

### Dev rules
- PF6 components. Use `hcc-patternfly-data-view` MCP for docs/examples/source.
- React 19. Functional, hooks, composition. No classes.
- TS strict. `no-explicit-any` enforced → `unknown` + narrowing. Tests: `as unknown as X` OK.
- LSP `get_diagnostics` before commit.
- **npm scripts only** — `npm test`, `npm run lint`, `npm run lint:fix`, `npm run lint:css`. Never `npx jest`/`npx eslint` direct.
- **Sequential npm commands only** — parallel → OOMKill.

### Code conventions

**Components**: Small files. 1 component, 1 job. Split ~250 lines. Repeated JSX → extract + iterate. `useMemo`/`useCallback` only when needed.

**State**: Cross-plugin → Scalprum shared stores via `@fleetshift/common`. Intra-plugin → React hooks (local). API → `api.ts` per plugin, typed fetch against `/v1/*`.

**Plugins**: Dir `src/plugins/<name>-plugin/` — components, `api.ts`, hooks, types. `DynamicRemotePlugin` in `rspack.config.ts`. `ScalprumComponent` `module` must match `exposedModules` key — no `./` prefix.

**Imports**: Side-effect → node_modules → local. `simple-import-sort` enforced. `npm run lint:fix` to sort.

**Formatting**: ESLint flat config + Prettier (double quotes, trailing commas). Stylelint for CSS/SCSS.

### SCSS

BEM + prefix. Prevents MF collisions.

| Scope | Prefix |
|-------|--------|
| Shell | `ome-` |
| Core | `ome-core-` |
| Overview | `ome-overview-` |
| GCP HCP | `ome-gcphcp-` |
| Settings | `ome-settings-` |
| Others | `ome-<short>-` (see AGENTS.md) |

PF utility classes first (`pf-v6-u-mb-md`, `pf-v6-u-display-flex`). Custom `ome-*` only for multi-property or uncovered cases.

`clsx` for conditional classes. No template literals.

Vendor overrides (`pf-*`) ONLY nested inside `ome-*` — never top-level.

### Build

Rspack 2.x + `builtin:swc-loader`. PF barrel → granular via SWC `transformImport` + `PfModuleReplacementPlugin` from `@fleetshift/build-utils`. `@fleetshift/common` → MF `sharedModules`. Entry: async boundary (`index.ts` → `import("./bootstrap")`).

### Testing

Vitest + `@testing-library/react`. Pattern: `packages/*/src/**/__tests__/**/*.test.ts`. Edge cases, not happy-path snapshots. `fake-indexeddb` available for IDB mocking.

### Verification — UI changes

MUST visually verify before PR. App on port 8085. `/debug` for plugin troubleshooting. `chrome-devtools` MCP (`browser_screenshot`, `browser_snapshot`). Don't build just to verify — LSP + browser MCP.

Never commit screenshots. Upload via `/gh-release-upload` → ref URLs in PR.

### Verification — non-UI
LSP diagnostics + `npm run lint` + `npm test`.

### Commands

```bash
npm run build:all    # common → plugins → GUI → merge
npm run lint         # eslint + stylelint
npm run lint:fix     # auto-fix
npm run lint:css     # stylelint only
npm test             # vitest
```

### Key deps

React 19, react-router-dom 7, PF react-core/table/data-view/charts/component-groups 6, Scalprum, @module-federation/enhanced 2, @dnd-kit/react, @orama/orama, motion, oidc-client-ts + react-oidc-context, leaflet + react-leaflet, clsx, PF react-code-editor + react-log-viewer.

### Diagrams

`docs/diagrams/` — LikeC4 `.c4`. Code > diagrams. Changed relevant code → validate `.c4` matches.
