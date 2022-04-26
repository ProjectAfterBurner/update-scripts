#!/bin/bash

source functions.sh || echo "Failed to source functions... this script cannot run." && exit 1

installdepends || error "installdepends failed to run."