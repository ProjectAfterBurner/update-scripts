#!/bin/bash

# get the github token for api requests
if [ ! -f "$HOME/token.sh" ]; then
    error "$HOME/token.sh not found. You need a GitHub API token to use these scripts."
fi
token="$(cat ~/token.sh)"

function error { # print red text and exit
  echo -e "\e[91m$1\e[39m"
  exit 1
}

function red { # simply print red text
  echo -e "\e[91m$1\e[39m"
}

function warning() { # yellow text, doesn't exit program
  echo -e "\e[93m\e[5m◢◣\e[25m WARNING: $1\e[0m" 1>&2
}

function status() { # cyan text to show what's happening
  # detect if a flag was passed, and if so, pass it on to the echo command
  if [[ "$1" == '-'* ]] && [ ! -z "$2" ];then
    echo -e $1 "\e[96m$2\e[0m" 1>&2
  else
    echo -e "\e[96m$1\e[0m" 1>&2
  fi
}

function green() { # announce the success of an action in green text
  echo -e "\e[92m$1\e[0m" 1>&2
}

function pkg-manage() {
    #usage: pkg-manage install "package1 package2 package3"
    #pkg-manage uninstall "package1 package2 package3"
    #pkg-manage check "packag1 package2 package3"
    #pkg-manage clean
    #
    #$1 is the operation: install or uninstall
    #$2 is the packages to operate on.
    if [[ "$1" == "install" ]]; then
        TOINSTALL="$(dpkg -l $2 2>&1 | awk '{if (/^D|^\||^\+/) {next} else if(/^dpkg-query:/) { print $6} else if(!/^[hi]i/) {print $2}}' | tr '\n' ' ')"
        sudo apt -f -y install $TOINSTALL || sudo apt -f -y install "$TOINSTALL"
    elif [[ "$1" == "uninstall" ]]; then
        sudo apt purge $2 -y
    elif [[ "$1" == "check" ]]; then
        TOINSTALL="$(dpkg -l $2 2>&1 | awk '{if (/^D|^\||^\+/) {next} else if(/^dpkg-query:/) { print $6} else if(!/^[hi]i/) {print $2}}' | tr '\n' ' ')"  
    elif [[ "$1" == "clean" ]]; then
        sudo apt clean
        sudo apt autoremove -y
        sudo apt autoclean
    else
        error "operation not specified!"
    fi
}

function getrelease { # grab the latest github release
    release="$(curl -s --header "Authorization: token $token" https://api.github.com/repos/${orgname}/${reponame}/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' | tr -d 'v')"
}

function checkifexists { # check if given url's are valid
    if [[ ! -z ${allurl+z} ]]; then
        if wget -q --method=HEAD ${allurl}; then
            echo "all url exists."
        else
            error "all url does not exist."
        fi
    elif [[ ! -z ${armhfurl+z} ]]; then
        if wget -q --method=HEAD ${armhfurl}; then
            echo "armhf url exists."
        else
            error "armhf url does not exist."
        fi
    elif [[ ! -z ${arm64url+z} ]]; then
        if wget -q --method=HEAD ${arm64url}; then
            echo "arm64 url exists."
        else
            error "armhf url does not exist."
        fi
    else
        echo "no urls provided."
    fi
}

function installdepends { # install/compile dependencies
    if ! command -v reprepro; then
        # compiles a special version of reprepro that 
        # allows multiple versions of the same package.
        echo "reprepro not installed, taking care of it now."
        pkg-manage install "git devscripts dh-make" || error "Failed to run pkg-manage 1."
        git clone https://github.com/ionos-cloud/reprepro || error "Failed to clone reprepro repository"
        cd reprepro
        sudo mk-build-deps -i debian/control || error "Failed to run mk-build-deps."
        dpkg-buildpackage -us -uc -nc || error "Failed to run dpkg-buildpackage."
        sudo apt install -y ../reprepro_*.deb || error "Failed to install reprepro from built deb."
        cd ../ && rm -rf ./reprepro/ ./reprepro*.deb
    else 
        echo "reprepro is installed. continuing."
    fi

    pkg-manage install "pinentry-tty gnupg"
}
