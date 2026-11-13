#!/usr/bin/env bash
# Build every apps/<slug> into dist/pages for one Cloudflare Pages project.
# apps/<slug> is published at /<slug>/.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${root}/dist/pages"
rm -rf "${out}"
mkdir -p "${out}"

shopt -s nullglob

slugs=()

for app_dir in "${root}/apps"/*/; do
  slug="$(basename "${app_dir}")"
  case "${slug}" in
    .*) continue ;;
  esac

  if [[ ! "${slug}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "::error::apps/${slug} must be a lowercase kebab-case slug."
    exit 1
  fi
  if [[ ! -f "${app_dir}/package.json" ]]; then
    echo "::error::apps/${slug} has no package.json."
    exit 1
  fi
  if [[ ! -f "${app_dir}/bunfig.toml" ]]; then
    echo "::error::apps/${slug} is missing bunfig.toml. Add [install] minimumReleaseAge = 259200 before bun install."
    exit 1
  fi
  if ! grep -Eq 'minimumReleaseAge[[:space:]]*=[[:space:]]*259200' "${app_dir}/bunfig.toml"; then
    echo "::error::apps/${slug}/bunfig.toml must set minimumReleaseAge = 259200 under [install]."
    exit 1
  fi

  echo "Building apps/${slug} (BASE_PATH=/${slug}/)"
  (
    cd "${app_dir}"
    bun install
    BASE_PATH="/${slug}/" bun run build
  )

  build_dir=""
  for candidate in dist build out .output/public; do
    if [[ -d "${app_dir}/${candidate}" ]]; then
      build_dir="${app_dir}/${candidate}"
      break
    fi
  done
  if [[ -z "${build_dir}" ]]; then
    echo "::error::apps/${slug} did not write static output to dist/, build/, out/, or .output/public/."
    exit 1
  fi

  mkdir -p "${out}/${slug}"
  cp -a "${build_dir}/." "${out}/${slug}/"
  slugs+=("${slug}")
done

{
  echo '<!DOCTYPE html>'
  echo '<html lang="en">'
  echo '<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Tech demos</title></head>'
  echo '<body>'
  echo '<h1>Tech demos</h1>'
  if [[ "${#slugs[@]}" -eq 0 ]]; then
    echo '<p>No demos in apps/ yet.</p>'
  else
    echo '<ul>'
    for slug in "${slugs[@]}"; do
      printf '<li><a href="/%s/">%s</a></li>\n' "${slug}" "${slug}"
    done
    echo '</ul>'
  fi
  echo '</body>'
  echo '</html>'
} > "${out}/index.html"

if [[ "${#slugs[@]}" -gt 0 ]]; then
  : > "${out}/_redirects"
  for slug in "${slugs[@]}"; do
    # Static files that exist are served as-is. This fallback covers client-side routes.
    printf '/%s/* /%s/index.html 200\n' "${slug}" "${slug}" >> "${out}/_redirects"
  done
fi

echo "Assembled ${#slugs[@]} app(s) into ${out}"
