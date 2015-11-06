#!/usr/bin/env sh

targetos=`uname -s`

if [ "$targetos" != "Darwin" ]; then
    # Install Linux Deps
    apt-get update -qq
    apt-get install -y libx11-dev libxext-dev x11proto-video-dev libxv-dev
fi
