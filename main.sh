#!/bin/bash

source api

# Check for updates
echo "Checking for script updates..."
localhash="$(git rev-parse HEAD)"
latesthash="$(git ls-remote https://github.com/ProjectAfterBurner/update-scripts.git HEAD | awk '{print $1}')"
if [ "$localhash" != "$latesthash" ] && [ ! -z "$latesthash" ] && [ ! -z "$localhash" ];then
    echo "Out of date, updating now..."
    git clean -fd
    git reset --hard
    git pull https://github.com/ProjectAfterBurner/update-scripts.git HEAD || error 'Unable to update, please check your internet connection'
else
    echo "Script is up to date."
fi


# create data directory, for storing the version.txt file
mkdir -p $PKGDIR
mkdir -p $DATADIR

# ensure armhf arch is added, needed for apt to download armhf software
sudo dpkg --add-architecture armhf

# check/download each package
for script in `ls scripts`; do
    unset API
    unset allurl
    unset armhfurl
    unset arm64url
    chmod +x scripts/$script
    source scripts/$script || error "sourcing of $script failed!"
    
    txtfile="$DATADIR/${script::-3}.txt"

    if [ ! -f ${txtfile} ]; then
        echo "JustCreatedThisFile" > ${txtfile}
    fi
    
    cattxt=`cat ${txtfile}`
    
    if [[ ${cattxt} == ${API} ]]; then
        unset API
        unset allurl
        unset armhfurl
        unset arm64url
        continue
    else
        echo "updating ${script::-3}"
    fi

    if [[ ! -z ${allurl} ]]; then
        echo "allurl"
        if wget -q --method=HEAD ${allurl}; then
            wget ${allurl} -O ${script::-3}.deb || error "failed to download ${allurl}"
            mv ${script::-3}*.deb $PKGDIR
            rm -rf ${script::-3}*.deb
            unset allurl
        else
            error "all url does not exist."
        fi
    elif [[ ! -z $armhfurl ]]; then
        echo "armhfurl"
        if wget -q --method=HEAD ${armhfurl}; then
            wget ${armhfurl} -O ${script::-3}.deb || error "failed to download ${armhfurl}"
            mv ${script::-3}*.deb $PKGDIR
            rm -rf ${script::-3}*.deb
            unset armhfurl
        else
            error "armhf url does not exist."
        fi
    elif [[ ! -z ${arm64url} ]]; then
        echo "arm64url"
        if wget -q --method=HEAD ${arm64url}; then
            wget ${arm64url} -O ${script::-3}.deb || error "failed to download ${arm64url}"
            mv ${script::-3}*.deb $PKGDIR
            rm -rf ${script::-3}*.deb
            unset arm64url
        else
            error "armhf url does not exist."
        fi
    else
        error "no urls provided."
    fi
    
    echo ${API} > ${txtfile}
done

status "Writing packages."
cd $HOME/projectafterburner-apt/rpi
for new_pkg in `ls pkgs_incoming`; do
    status $new_pkg
    cd $HOME/projectafterburner-apt/rpi || error "failed to enter dir"
    #reprepro_expect, so that the password entry can be automated
    $HOME/reprepro.exp -- --noguessgpgtty -Vb $HOME/projectafterburner-apt/rpi/ includedeb bullseye $HOME/projectafterburner-apt/rpi/pkgs_incoming/$new_pkg
    if [ $? != 0 ]; then
        red "Import of $new_pkg failed!"
    else
        rm -rf pkgs_incoming/$new_pkg
    fi
    cd $HOME/projectafterburner-apt
    git add . || error "Failed to run git add"
    git commit -m "Updated $new_pkg" || error "Failed to run git commit $new_pkg"
    git push origin main || error "Failed to run git push origin main!"
    cd $HOME/projectafterburner-apt/rpi || error "failed to enter dir"
done
echo "script complete."
