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