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
    echo "Up to date."
fi


# create data directory, for storing the version.txt file
mkdir -p $PKGDIR
mkdir -p $DATADIR

# ensure armhf arch is added, needed for apt to download armhf software
sudo dpkg --add-architecture armhf

# check/download each package
for script in `ls scripts`; do
    chmod +x scripts/$script
    source scripts/$script || error "sourcing of $script failed!"
    
    txtfile=`cat $DATADIR/${script::-3}.txt`

    if [ ! -f ${txtfile} ]; then
        echo "JustCreatedThisFile" > ${txtfile}
    fi
    
    if [[ "${txtfile}" == ${API} ]]; then
        continue
    else
        echo "updating ${script::-3}"
    fi

    if [[ ! -z ${allurl+z} ]]; then
        if wget -q --method=HEAD ${allurl}; then
            wget -q ${allurl} || error "failed to download ${allurl}"
            mv ${script::-3}*.deb $PKGDIR
        else
            error "all url does not exist."
        fi
    elif [[ ! -z ${armhfurl+z} ]]; then
        if wget -q --method=HEAD ${armhfurl}; then
            wget -q ${armhfurl} || error "failed to download ${armhfurl}"
            mv ${script::-3}*.deb $PKGDIR
        else
            error "armhf url does not exist."
        fi
    elif [[ ! -z ${arm64url+z} ]]; then
        if wget -q --method=HEAD ${arm64url}; then
            wget -q ${arm64url} || error "failed to download ${arm64url}"
            mv ${script::-3}*.deb $PKGDIR
        else
            error "armhf url does not exist."
        fi
    else
        error "no urls provided."
    fi
    
    echo ${API} > $DATADIR/${script::-3}.txt
    
done

status "Writing packages."
cd $HOME/projectafterburner-apt/rpi
for new_pkg in `ls pkgs_incoming`; do
    status $new_pkg
    cd $HOME/projectafterburner-apt/rpi || error "failed to enter dir"
    #reprepro_expect, so that the password entry can be automated
    $HOME/reprepro.exp -- --noguessgpgtty -Vb $HOME/projectafterburner-apt/rpi/ includedeb precise $HOME/projectafterburner-apt/rpi/pkgs_incoming/$new_pkg
    if [ $? != 0 ]; then
        red "Import of $new_pkg failed!"
    else
        rm -rf pkgs_incoming/$new_pkg
    fi
    cd $HOME/projectafterburner-rpi 
    git add . || error "Failed to run git add"
    git commit -m "Updated $new_pkg" || error "Failed to run git commit $new_pkg"
    git push origin main || error "Failed to run git push origin main!"
    cd $HOME/projectafterburner-apt/rpi || error "failed to enter dir"
done
echo "script complete."
