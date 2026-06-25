#!/usr/bin/env bash

set -eu

DOWNLOADS_API="https://support.kagamistudio.com/api/downloads"
BASE_URL="https://support.kagamistudio.com"

script='
(.[] | select(.key == "PrismTerminal")).latestRelease
| {
    version: .version,
    entry: (.entries | .[] | select(.variant == "deb"))
  }
| [ .version, .entry.downloadUrl, .entry.checksumSha256 ] | join(" ")'

result="$(curl -sSL $DOWNLOADS_API | jq -r "$script")"
read -r version downloadUrl sha256 <<< "$result"

fullUrl="$BASE_URL$downloadUrl"

echo "Version: $version"
echo "Download: $fullUrl"
echo "Sha256: $sha256"

encodedSha="sha256-$(echo -n "$sha256" | xxd -r -p | base64)"

echo "Encoded Sha256: $encodedSha"

echo "{
  version = \"$version\";
  release = \"$fullUrl\";
  hash = \"$encodedSha\";
}" > app-info.nix