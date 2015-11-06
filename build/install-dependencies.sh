#!/usr/bin/env sh

if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    # Install Linux Deps
    sudo apt-get update -qq
    sudo apt-get install -y libx11-dev libxext-dev x11proto-video-dev libxv-dev
fi
