#!/bin/bash

DIR=$(cd $(dirname "$0"); pwd)

source $DIR/init.sh

# do build

bitbake linaro-image-sdk

prepare_for_publish
