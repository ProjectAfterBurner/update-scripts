#!/bin/bash

source functions.sh || echo "Failed to source functions... this script cannot run." && exit 1

if ! command -v reprepro; then
    error "reprepro not found! see the readme"
else
    echo "reprepro found, continuing."
fi

