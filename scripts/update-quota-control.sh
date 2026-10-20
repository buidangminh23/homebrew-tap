#!/usr/bin/env bash
set -euo pipefail

repo="buidangminh23/quota-control"
cask="$(cd "$(dirname "$0")/.." && pwd)/Casks/quota-control.rb"

tag=""
allow_downgrade=false
while [[ $# -gt 0 ]]
do
  case "$1" in
    --tag)
      tag="${2:-}"
      shift 2
      ;;
    --allow-downgrade)
      allow_downgrade=true
      shift
      ;;
    *)
      echo "unknown option $1" >&2
      exit 1
      ;;
  esac
done

current="$(sed -n 's|^  version "\(.*\)"$|\1|p' "${cask}")"
if [[ -z "${current}" ]]
then
  echo "could not read the current version from ${cask}" >&2
  exit 1
fi

if [[ -z "${tag}" ]]
then
  tag="$(gh release view --repo "${repo}" --json tagName --jq .tagName)"
fi
version="${tag#v}"
if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
  echo "unexpected release tag ${tag}" >&2
  exit 1
fi

if [[ "${current}" == "${version}" ]]
then
  echo "quota-control is already at ${version}"
  exit 0
fi
newest="$(printf '%s\n%s\n' "${current}" "${version}" | sort -V)"
newest="${newest##*$'\n'}"
if [[ "${allow_downgrade}" != true && "${newest}" != "${version}" ]]
then
  echo "release ${version} is older than the cask's ${current}; leaving it alone (pass --allow-downgrade to move back)" >&2
  exit 0
fi

dmg="Quota-Control_${version}_aarch64.dmg"
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

if ! gh release download "${tag}" --repo "${repo}" --pattern SHA256SUMS --dir "${workdir}"
then
  echo "release ${tag} has no SHA256SUMS" >&2
  exit 1
fi
listed="$(awk -v name="${dmg}" '$2 == name || $2 == "*" name { print $1 }' "${workdir}/SHA256SUMS")"
if [[ -z "${listed}" ]]
then
  echo "release ${tag} ships no ${dmg}; the cask stays at ${current}"
  exit 0
fi
if [[ ! "${listed}" =~ ^[0-9a-f]{64}$ ]]
then
  echo "SHA256SUMS lists a malformed checksum for ${dmg}" >&2
  exit 1
fi

if ! gh release download "${tag}" --repo "${repo}" --pattern "${dmg}" --dir "${workdir}"
then
  echo "release ${tag} lists ${dmg} but does not carry it" >&2
  exit 1
fi
sha256="$(shasum -a 256 "${workdir}/${dmg}" | cut -d' ' -f1)"
if [[ "${sha256}" != "${listed}" ]]
then
  echo "${dmg} does not match its SHA256SUMS entry" >&2
  exit 1
fi

sed -i.bak \
  -e "s|^  version \".*\"$|  version \"${version}\"|" \
  -e "s|^  sha256 \".*\"$|  sha256 \"${sha256}\"|" \
  "${cask}"
rm -f "${cask}.bak"
if ! grep -q "^  version \"${version}\"$" "${cask}" || ! grep -q "^  sha256 \"${sha256}\"$" "${cask}"
then
  echo "could not write ${version} and its checksum into ${cask}" >&2
  exit 1
fi

echo "quota-control ${current} -> ${version}"
if [[ -n "${GITHUB_OUTPUT:-}" ]]
then
  {
    echo "updated=true"
    echo "previous=${current}"
    echo "version=${version}"
    echo "tag=${tag}"
    echo "sha256=${sha256}"
  } >>"${GITHUB_OUTPUT}"
fi
