#!/usr/bin/env bash
set -euo pipefail

package="@minhspark/codex-mcp-bridge"
formula="$(cd "$(dirname "$0")/.." && pwd)/Formula/codex-mcp-bridge.rb"
registry="https://registry.npmjs.org"

metadata="$(curl -fsSL "${registry}/${package}/latest")"
version="$(jq -r '.version' <<<"${metadata}")"
tarball="$(jq -r '.dist.tarball' <<<"${metadata}")"
integrity="$(jq -r '.dist.integrity' <<<"${metadata}")"

if [[ -z "${version}" || "${version}" == null || -z "${tarball}" || "${tarball}" == null ]]
then
  echo "registry returned no version or tarball for ${package}" >&2
  exit 1
fi

current="$(sed -n 's|^  url "https://registry.npmjs.org/.*-\([0-9][^"]*\)\.tgz"$|\1|p' "${formula}")"
if [[ -z "${current}" ]]
then
  echo "could not read the current version from ${formula}" >&2
  exit 1
fi
if [[ "${current}" == "${version}" ]]
then
  echo "codex-mcp-bridge is already at ${version}"
  exit 0
fi
newest="$(printf '%s\n%s\n' "${current}" "${version}" | sort -V)"
newest="${newest##*$'\n'}"
if [[ "${newest}" != "${version}" ]]
then
  echo "registry latest ${version} is older than the formula's ${current}; leaving it alone" >&2
  exit 0
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
curl -fsSL -o "${workdir}/package.tgz" "${tarball}"

expected="${integrity#sha512-}"
actual="$(openssl dgst -sha512 -binary "${workdir}/package.tgz" | openssl base64 -A)"
if [[ "${integrity}" != sha512-* || "${expected}" != "${actual}" ]]
then
  echo "downloaded tarball does not match the registry's integrity ${integrity}" >&2
  exit 1
fi

sha256="$(shasum -a 256 "${workdir}/package.tgz" | cut -d' ' -f1)"

sed -i.bak \
  -e "s|^  url \".*\"$|  url \"${tarball}\"|" \
  -e "s|^  sha256 \".*\"$|  sha256 \"${sha256}\"|" \
  "${formula}"
rm -f "${formula}.bak"

echo "codex-mcp-bridge ${current} -> ${version}"
if [[ -n "${GITHUB_OUTPUT:-}" ]]
then
  {
    echo "updated=true"
    echo "previous=${current}"
    echo "version=${version}"
    echo "sha256=${sha256}"
  } >>"${GITHUB_OUTPUT}"
fi
