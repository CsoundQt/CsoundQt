#!/usr/bin/env bash
set -euo pipefail

# Prints the latest commit hash for each repo/branch, in the form:
#   <url>: <commit>

REPOS=(
    "https://github.com/csound-plugins/csound-plugins master"
    "https://github.com/csound/csound develop"
    "https://github.com/CsoundQt/CsoundQt.git csoundqt7"
)

for entry in "${REPOS[@]}"; do
    url="${entry% *}"
    branch="${entry##* }"
    commit="$(git ls-remote "$url" "refs/heads/$branch" | cut -f1)"
    if [[ -z "$commit" ]]; then
        echo "error: no commit found for $url (branch $branch)" >&2
        exit 1
    fi
    echo "$url (branch $branch): $commit"
done

checksum=$(curl -s https://api.github.com/repos/csound/manual/releases/tags/latest | jq -r '.assets[] | select(.name == "csound7-manual-offline.zip") | .digest' | cut -d: -f2)
echo "csound manual sha256: $checksum"
