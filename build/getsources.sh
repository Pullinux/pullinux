#!/bin/bash

mkdir -p sources

RELEASE_ID=$(curl -s https://api.github.com/repos/Pullinux/pullinux/releases | jq '.[] | select(.tag_name=="1.1") | .id')
PAGE=1

while :
do
    URL="https://api.github.com/repos/pullinux/pullinux/releases/$RELEASE_ID/assets?per_page=100&page=$PAGE"
    echo "Fetching asset list (page $PAGE)..."
    JSON=$(curl -sL "$URL")
    COUNT=$(jq 'length' <<<"$JSON")

    if [ "$COUNT" == "0" ]; then
        break
    fi

    echo "$JSON" | jq -r '.[] | [.name, .browser_download_url] | @tsv' |
    while IFS=$'\t' read -r NAME DLURL; do

        if [[ -f "sources/$NAME" ]]; then
            echo "Already exists: $NAME (skipping)"
            continue
        fi
        
        echo "Downloading: $NAME"
        curl -sL --fail --retry 3 --retry-delay 2 -o "sources/$NAME" "$DLURL"
    done

    ((PAGE++))
done

echo ""
echo "Finished downloading sources"
