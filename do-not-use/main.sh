#!/bin/bash

# Check for updates
echo "Checking for script updates..."
localhash="$(git rev-parse HEAD)"
latesthash="$(git ls-remote https://github.com/ProjectAfterBurner/update-scripts.git HEAD | awk '{print $1}')"
if [ "$localhash" != "$latesthash" ] && [ ! -z "$latesthash" ] && [ ! -z "$localhash" ];then
    echo "Out of date, updating now..."
    git clean -fd
    git reset --hard
    git pull https://github.com/ProjectAfterBurner/update-scripts.git HEAD || error "Unable to update, please check your internet connection."
else
    echo "Up to date."
fi

source functions.sh || echo "Failed to source functions... this script cannot run." && exit 1

if ! command -v reprepro; then
    error "reprepro not found! see the readme"
else
    echo "reprepro found, continuing."
fi

# create a working directory
if [ -d /tmp/projectafterburner-apt ]; then
    sudo rm -rf /tmp/projectafterburner-apr
else
    mkdir -p /tmp/projectafterburner-apr
fi

# check ver for each package
for script in `ls packages`; do
    script2=${script::-3}

    chmod +x packages/$script
    bash packages/$script || red "Execution of $script failed!"
done

