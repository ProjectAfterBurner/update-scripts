#!/bin/bash

API="$(get_release SpacingBat3/WebCord)"

allurl=""
armhfurl="https://github.com/SpacingBat3/WebCord/releases/download/v${API}/webcord_${API}_armhf.deb"
arm64url="https://github.com/SpacingBat3/WebCord/releases/download/v${API}/webcord_${API}_arm64.deb"