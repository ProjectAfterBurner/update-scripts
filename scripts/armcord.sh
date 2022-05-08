#!/bin/bash

API="$(get_release ArmCord/ArmCord)"

allurl=""
arm64url="https://github.com/ArmCord/ArmCord/releases/download/v${API}/ArmCord_${API}_arm64.deb"