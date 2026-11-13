# Tech demos

One monorepo for small public-tech playground demos. Every demo is added under `apps/<slug>/` in this repository.

## Layout

| Path | Purpose |
| --- | --- |
| `apps/<slug>/` | One self-contained Bun app |
| `skills/project-planning/` | Planning skill to follow before building a demo |
| `tracking/seen-bookmarks.json` | Proposed, built, and skipped demos |
| `scripts/assemble-pages.sh` | Builds every app into one Pages output tree |
| `.github/workflows/cloudflare-pages.yml` | Deploys that tree to Cloudflare Pages |
| `bunfig.toml` | Repo Bun install policy (`minimumReleaseAge = 259200`) |
| `AGENTS.md` | Standing instructions for agents adding demos |

## How a demo lands

1. Plan with `skills/project-planning/SKILL.md` and write `apps/<slug>/PLAN.md` before building.
2. Add the app under `apps/<slug>/`. From that directory it runs with `bun install && bun run dev`. Include `bunfig.toml` with `[install] minimumReleaseAge = 259200` before `bun install`.
3. Open one pull request and attach at least one screenshot and at least one video of the running app.

`<slug>` is lowercase kebab-case, for example `apps/particle-sandbox/`.

## Preview deploys

Previews use one Cloudflare Pages project, named `tech-demos`, with a path per app. `apps/<slug>/` is published at `/<slug>/` on that project. The site root lists those paths. Create the `tech-demos` Pages project yourself as a direct-upload project before expecting a live deploy. The workflow deploys to that existing project.

The workflow is `.github/workflows/cloudflare-pages.yml`. It runs on pull requests, on pushes to `main`, and from the Actions tab. Set these GitHub Actions secrets on this repository (Settings → Secrets and variables → Actions):

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

If either secret is missing, the workflow fails and does not print secret values.

Each app needs a `build` script. The workflow sets `BASE_PATH` to `/<slug>/` and publishes the first directory it finds among `dist/`, `build/`, `out/`, and `.output/public`.
