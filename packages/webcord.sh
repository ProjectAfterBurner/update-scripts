#!/bin/bash

source ../functions.sh

orgname="SpacingBat3"
reponame="WebCord"

getrelease || error "Failed to get release."

# provided the URLs here, check if they are valid and error if not
armhfurl="https://github.com/SpacingBat3/WebCord/releases/download/v${release}/webcord_${release}_armhf.deb"
arm64url="https://github.com/SpacingBat3/WebCord/releases/download/v${release}/webcord_${release}_arm64.deb"

checkifexists || error "one or more URLs aren't valid."

