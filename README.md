# fleetshift-bot-instance

Custom bot runner instance built on [dev-bot](https://github.com/RedHatInsights/platform-frontend-ai-dev).

## Native OpenCode V2

FleetShift selects `runtime: opencode`, `provider: rehor-openai`, and `model: gpt-6-luna`. The merged shared runtime is pinned to `e6b0fda738c71b8be694b8711cf32e53eee59c9b` (OpenCode CLI/client 2.1.2). The workflow remains `jira-sprint` with `node`, `go`, `patternfly-mcp`, `slack`, and `container-scan` environments.

Configuration has two owners:

| File | Purpose |
| --- | --- |
| `instance/fleetshift-config/agent/instance.yaml` | Runtime, provider, model, workflow, and environment selection; synced each cycle. |
| `instance/fleetshift-config/agent/AGENTS.md` | Native instance guidance alongside shared core/workflow instructions; no Claude assembly strategy. |
| `instance/fleetshift-config/agent/opencode.json` | Selects `fleetshift-coordinator` as primary, limits delegation depth to one, and permits delegation only to `backend` and `frontend`. |
| `instance/fleetshift-config/agent/.opencode/agents/{fleetshift-coordinator,backend,frontend}.md` | Native primary coordinator and two actual subagents. Existing backend/frontend persona guidance is carried in their agent system prompts, with repository scope and worker boundaries. |
| `instance/fleetshift-config/agent/mcp.json` | Jira endpoint reference plus PatternFly's installed `hcc-pf-mcp` executable; shared memory and optional servers still come from the runner. |
| `instance/fleetshift-config/opencode-deployment.json` | Deployment-owned native Responses provider, declared Luna model, medium reasoning, environment references, empty `packages` list, and approved external directories. Baked into the image. |

The runner workspace is `/home/botuser/app`. External access is limited to `/home/botuser/repos` (project checkouts), `/home/botuser/data` (persistent state), and `/tmp/opencode` (task scratch). The coordinator renders these as ordered permissions and a global native policy ceiling; profile/project agent grants cannot widen that ceiling. No additional providers or package plugins are configured. The empty legacy instance `skills/` directory has no custom skills to migrate; shared/workflow/environment helper installation remains runtime-owned.

`deploy/template.yaml` supplies:

```text
BOT_EXECUTION_ENGINE=coordinator
REHOR_OPENCODE_DEPLOYMENT_CONFIG=/home/botuser/app/instance/fleetshift-config/opencode-deployment.json
REHOR_OPENCODE_MAX_TOOL_CALLS=200
REHOR_WORKSPACE_OWNER_UID=1000
REHOR_MODEL_PROXY_URL=http://devbot-proxy:8450/v1
REHOR_MODEL_PROXY_TOKEN=rehor-runtime
```

The token is a non-secret client placeholder; the shared OpenAI gateway injects upstream credentials. The NetworkPolicy allows TCP/8450 only to the existing proxy selector. The shared proxy's `OPENAI_ALLOWED_MODELS` must include `gpt-6-luna`; `VERTEX_ALLOWED_MODELS` does not authorize OpenAI models. Required template parameters `GCP_PROJECT_ID`, `GCP_REGION`, and `VERTEX_ALLOWED_MODELS` remain as a deprecated caller contract because existing GitOps supplies them. They do not select FleetShift's provider or model. Claude-specific workload environment entries are removed; unrelated identity, repository, scheduling, and build settings are retained.

## Supported repositories

This FleetShift instance supports [OCM Fleet](https://github.com/stolostron/ocm-fleet) and [Scaffolding](https://github.com/scalprum/scaffolding), selected by canonical repository labels. Profile: `instance/fleetshift-config/agent/`; the `backend` persona covers OCM Fleet backend/CLI work, and `frontend` covers OCM Fleet UI and Scaffolding work.

### OCM Fleet

OCM Fleet is a monorepo containing the Go resource manager (`server/`), TypeScript CLI (`client/cli/`), React web UI (`client/web/`), UI plugins (`extensions/core/client/`, `extensions/kind/client/`), shared SDK (`sdk/common/`, `sdk/build-utils/`), and protobuf sources (`proto/`). The UI is part of this monorepo; there is no standalone UI checkout or PR workflow.

- **Canonical repo key:** `stolostron/ocm-fleet`
- **Bot fork / push destination:** `https://github.com/platex-rehor-bot/ocm-fleet.git`
- **Upstream / PR destination:** `https://github.com/stolostron/ocm-fleet.git`, base `main`
- **Jira labels:** `ome-ai-bot` and `repo:stolostron/ocm-fleet`

Repository rules live in upstream root `AGENTS.md`; UI-specific rules live in `docs/ui/AGENTS.md`. The workspace uses npm and Nx. Install dependencies at the monorepo root with `npm install`, then discover projects and targets with `npm exec nx show projects` and `npm exec nx show project <project>`. Persona prompts provide focused verification examples rather than a second architecture reference.

### Scaffolding

- **Canonical repo key:** `scalprum/scaffolding`
- **Bot fork / push destination:** `https://github.com/platex-rehor-bot/scaffolding.git`
- **Upstream / PR destination:** `https://github.com/scalprum/scaffolding.git`, base `main`
- **Jira labels:** `ome-ai-bot` and `repo:scalprum/scaffolding`

Scaffolding is an npm/Nx monorepo containing core, react-core, build-utils, react-test-utils, remote-types, and examples packages. Read upstream root `CLAUDE.md` and relevant package READMEs. Match `.nvmrc` and package engines (currently Node >=26 and npm >=11.14.1), run `npm ci` at the root, then discover projects and existing lint/test/typecheck/build targets with `npm exec nx show projects` and `npm exec nx show project <project>`. OCM Fleet paths and UI conventions apply only to OCM Fleet.

### Configuration rollout

Jira work must use `ome-ai-bot` and the selected repository's canonical label: `repo:stolostron/ocm-fleet` or `repo:scalprum/scaffolding`. Retired OCM migration labels (`repo:fleetshift/fleetshift-poc` and `repo:fleetshift/fleetshift-user-interface`) are unsupported; replace them rather than adding aliases, including on tickets that have multiple repo labels. The pinned preflight rejects a ticket if any `repo:` label is unmatched. Review active task repository metadata before resuming work against the migrated project.

The deployment must select `BOT_CONFIG_PATH=instance/fleetshift-config` in the configured instance repository. Instance identity, persona names, repository mappings, and canonical labels remain unchanged by the runtime migration.

The pinned repo loader merges repository keys additively: removing a key from this profile does not remove it from an already-generated runtime `project-repos.json`. Verify that the effective map contains exactly `stolostron/ocm-fleet` and `scalprum/scaffolding`; if retired entries remain, roll out a fresh runner filesystem using this profile rather than relying on config sync alone.

### Paired runtime rollout and rollback

Remote profile sync is independent of the image/template rollout. **Do not let the current Claude/Python runner consume this OpenCode profile.** Publishing the profile to the tracked config branch can affect the next cycle even while an old image is still running.

1. Before publishing the migration to the tracked config branch, pause FleetShift and prevent KEDA from restarting the old runner. Record the previous immutable image digest, template/engine settings, and compatible instance/config revision. Drain any active cycle.
2. Build and publish a fresh instance image with the pinned `dev-bot` gitlink. Reconcile the matching template, image, and profile together. Confirm `BOT_EXECUTION_ENGINE=coordinator`, the deployment-config path, proxy environment, TCP/8450 egress, and the proxy's Luna allowlist. Changing remote config or restarting an old image cannot install the V2 runtime or baked deployment config.
3. Start a fresh runner filesystem with the new image. Verify the synced profile revision, effective runtime/provider/model, coordinator plus backend/frontend native agents and delegation, environment tools, MCP connectivity, and the exact two-entry repository map before accepting work. Preserve the existing GitOps identity and `ome-ai-bot` label override; the template's label default is not the live selection.
4. Run one controlled staging `--once` cycle, then check task/terminal state, transcript, usage/cost accounting, tool-call budget, MCP behavior, and process cleanup before resuming the schedule.

To roll back, pause/drain the runner and hold scheduling again. Restore a Claude-compatible profile on the config repository's tracked default branch (for example, revert this migration), restore the recorded immutable Claude image and prior Python engine/template environment together, then start a fresh runner and verify its effective config before resuming. Image-only rollback is insufficient while remote sync still serves the OpenCode profile. This repository change does not deploy or validate a live rollout.

### Validation scope

Local acceptance covers the pinned Python instance/config loaders and merge behavior, coordinator native profile snapshot/render/validators, agent definitions and delegation permissions, model/provider/environment references, MCP grants, external-directory policy rendering, JSON/YAML parsing, local OpenShift template processing, and `git diff --check`. See the shared [OpenCode migration guide](https://github.com/OpenShift-Fleet/rehor/blob/e6b0fda738c71b8be694b8711cf32e53eee59c9b/docs/migrations/opencode-migration.md) for native/deployment gates.

Local config/render checks do not prove Linux image installation, real gateway allowlisting/authentication, MCP executable startup/connectivity, model inference, or live filesystem enforcement. Those require the fresh-image staging gates above. OpenCode 2.1.2 has no LSP runtime; use repository lint/typecheck/test commands instead of claiming LSP diagnostics. The existing environment selection does not include `browser`; UI/browser verification remains dependent on available browser tooling and must be reported as blocked if unavailable.

## Architecture

Uses dev-bot as a git submodule. The submodule ships `Dockerfile.runner` which builds the full bot image and runs instance-specific customization hooks from this repo.

```
fleetshift-bot-instance/
├── dev-bot/        # Git submodule (don't modify)
├── setup.sh        # Custom build steps (dnf install, pip install, etc.)
├── instance/       # Extra files COPYed into the image
└── README.md
```

No Dockerfile in this repo — Konflux points at `dev-bot/Dockerfile.runner`.

## Build

```bash
git submodule update --init --recursive
docker build -f dev-bot/Dockerfile.runner -t fleetshift-bot-instance:local .
```

## Customization

- **setup.sh** — runs as root during build. Install packages, write config, etc.
- **instance/** — files COPYed to `/home/botuser/app/instance/` in the image.

## Updating dev-bot

```bash
cd dev-bot && git pull origin master && cd ..
git add dev-bot
git commit -m "chore: update dev-bot submodule"
```

## Konflux

```yaml
dockerfile: dev-bot/Dockerfile.runner
path-context: .
```
