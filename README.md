# fleetshift-bot-instance

Custom bot runner instance built on [dev-bot](https://github.com/RedHatInsights/platform-frontend-ai-dev).

## Supported project

This FleetShift instance supports one repository: [OCM Fleet](https://github.com/stolostron/ocm-fleet), a monorepo containing the Go resource manager (`server/`), TypeScript CLI (`client/cli/`), React web UI (`client/web/`), UI plugins (`extensions/core/client/`, `extensions/kind/client/`), shared SDK (`sdk/common/`, `sdk/build-utils/`), and protobuf sources (`proto/`). The UI is part of this monorepo; there is no standalone UI checkout or PR workflow.

- **Canonical repo key:** `stolostron/ocm-fleet`
- **Bot fork / push destination:** `https://github.com/platex-rehor-bot/ocm-fleet.git`
- **Upstream / PR destination:** `https://github.com/stolostron/ocm-fleet.git`, base `main`
- **Profile:** `instance/fleetshift-config/agent/`, with `backend` and `frontend` personas sharing the same repository.

Repository rules live in upstream root `AGENTS.md`; UI-specific rules live in `docs/ui/AGENTS.md`. The workspace uses npm and Nx. Install dependencies at the monorepo root with `npm install`, then discover projects and targets with `npm exec nx show projects` and `npm exec nx show project <project>`. Persona prompts provide focused verification examples rather than a second architecture reference.

### Configuration rollout

Jira work must use `repo:stolostron/ocm-fleet`. With the new mapping, retired repo labels no longer resolve; replace them rather than adding aliases, including on tickets that have multiple repo labels. The pinned preflight rejects a ticket if any `repo:` label is unmatched. Review active task repository metadata before resuming work against the migrated project.

The deployment should select `BOT_CONFIG_PATH=instance/fleetshift-config` in the configured instance repository. After merging, verify remote-config sync picks up the updated profile and repo mapping. Instance identity, persona names, runtime/model settings, and deployment tool versions remain managed by their existing configuration.

The pinned repo loader merges repository keys additively: removing a key from this profile does not remove it from an already-generated runtime `project-repos.json`. Verify that the effective map contains only `stolostron/ocm-fleet`; if retired entries remain, roll out a fresh runner filesystem using this profile rather than relying on config sync alone.

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
