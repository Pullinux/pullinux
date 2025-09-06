#!/bin/bash
f=$1
curl -X POST -H "Authorization: token $PLX_TOKEN" -H "Content-Type: application/x-tar"         --data-binary @$f "https://uploads.github.com/repos/Pullinux/pullinux/releases/245204894/assets?name=$f"
