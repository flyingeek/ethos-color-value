#!/usr/bin/env bash

set -euo pipefail

SCRIPT_VER=$(grep -m 1 'local scriptVersion' "${2:-missingApp}"/main.lua | sed 's/.*"\(.*\)".*/\1/')
echo "scriptVersion    : ${SCRIPT_VER}"

if [[ -n $(git status --porcelain) ]]; then
  echo "Git working tree is not clean. Please commit or stash changes before running this script."
  git status --short
  exit 1
fi

script_version="${SCRIPT_VER}"
tag_input="${1:-release/<scriptVersion>}"
if [[ -z "${tag_input// }" || "$tag_input" == "release/<scriptVersion>" ]]; then
  tag="release/$script_version"
else
  tag="$tag_input"
fi

if [[ -z "${tag// }" ]]; then
  echo "Tag cannot be empty"
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  echo "Tag \"$tag\" already exists locally"
  echo "to delete: git tag -d \"$tag\" && git push --delete origin \"$tag\""
  exit 1
fi

echo "Creating tag \"$tag\" for version \"$script_version\"..."
git tag "$tag"
git push origin "$tag"
echo "Pushed tag \"$tag\" to origin"
