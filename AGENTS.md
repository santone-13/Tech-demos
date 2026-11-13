# Agent instructions

This repository is the one sticky monorepo for small public-tech playground demos. Add every demo here.

## Hard rules

- Never create a new GitHub repository.
- Bun is the runtime and the package manager. Use `bun` for installs, scripts, and the dev server.
- For a given demo, only add or update files under `apps/<kebab-slug>/`. The one exception: when recording a proposal or a completed build, append that record to `tracking/seen-bookmarks.json`.
- Leave every other app untouched.
- Each app is self-contained. From `apps/<kebab-slug>/` it runs with `bun install && bun run dev`.
- Before `bun install` or `bun add` in an app, that directory must contain `bunfig.toml` with:

```toml
[install]
minimumReleaseAge = 259200
```

The repo-root `bunfig.toml` uses the same policy. Do not remove or weaken it.

- Open one pull request for the demo.
- Attach both at least one screenshot and at least one video of the running app to that pull request. Both are required.
- Do not put secrets in the repo. Preview deploys read `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` from this repository's GitHub Actions secrets.

## Before building

1. Plan first with the in-repo skill at `skills/project-planning/SKILL.md`.
2. Write that plan to `apps/<kebab-slug>/PLAN.md` before building.
3. Build only inside `apps/<kebab-slug>/`.

`<kebab-slug>` is a short lowercase kebab-case directory name.

## Tracking

`tracking/seen-bookmarks.json` holds `proposed`, `built`, and `skipped`. Append one object when recording a proposal or a completed build. Include `slug`, `title`, and `source` (the bookmark URL when there is one). Append to `built` once the app exists under `apps/<slug>/`. Append to `skipped` with a `reason` when a candidate is declined. Do not rewrite existing entries.

## Preview deploy

GitHub Actions publishes this repo to one Cloudflare Pages project named `tech-demos`. Each `apps/<slug>/` is served at `/<slug>/` on that project. Provide `bun run build`, and write static files to `dist/`, `build/`, `out/`, or `.output/public`. The workflow sets `BASE_PATH` to `/<slug>/` for the build.
