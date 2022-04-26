#!/bin/bash

# Needed variables/functions for raspbian-addons autoupdate

PKGDIR="/root/raspbian-addons/debian/pkgs_incoming/" # directory for incoming, unwritten packages.

function error {
  echo -e "\e[91m$1\e[39m"
  exit 1
}

function red {
  echo -e "\e[91m$1\e[39m"
}

function warning() { #yellow text
  echo -e "\e[93m\e[5m◢◣\e[25m WARNING: $1\e[0m" 1>&2
}

function status() { #cyan text to indicate what is happening
  
  #detect if a flag was passed, and if so, pass it on to the echo command
  if [[ "$1" == '-'* ]] && [ ! -z "$2" ];then
    echo -e $1 "\e[96m$2\e[0m" 1>&2
  else
    echo -e "\e[96m$1\e[0m" 1>&2
  fi
}

function green() { #announce the success of an action
  echo -e "\e[92m$1\e[0m" 1>&2
}
