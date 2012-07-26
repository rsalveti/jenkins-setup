#!/bin/bash

DIR=$(cd $(dirname "$0"); pwd)

source $DIR/init.sh

# do build

bitbake -cfetchall pseudo-native
