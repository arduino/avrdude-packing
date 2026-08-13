#!/bin/bash -ex

# TODO: Determine version from git tags instead of hardcoding it here
AVRDUDE_VERSION=8.2
ARDUINO_TAG=arduino.1

run_build() {
  echo "Running build for $1"
  git clean -fdX
  tar xfv avrdude-8.2.tar.gz
  docker run -it --rm -w /build -v .:/build $2
  mv -f avrdude-${AVRDUDE_VERSION}-${ARDUINO_TAG}.tar.bz2 avrdude-${AVRDUDE_VERSION}-${ARDUINO_TAG}-$1.tar.bz2
}

# Download the source code archive for avrdude 8.2 if it doesn't exist
if [ ! -f avrdude-8.2.tar.gz ]; then
  wget https://github.com/avrdudes/avrdude/archive/refs/tags/v8.2.tar.gz -O avrdude-8.2.tar.gz
fi

run_build Linux-32bit ghcr.io/arduino/crossbuild-linux-i686:ubuntu-18.04-1
run_build Linux-64bit ghcr.io/arduino/crossbuild-linux-amd64:ubuntu-16.04-1
run_build Linux-armhf ghcr.io/arduino/crossbuild-linux-armhf:ubuntu-16.04-1
run_build Linux-arm64 ghcr.io/arduino/crossbuild-linux-arm64:ubuntu-16.04-1

run_build MacOS-64bit ghcr.io/arduino/crossbuild-macos-amd64:ubuntu-24.04-1
run_build MacOS-arm64 ghcr.io/arduino/crossbuild-macos-arm64:ubuntu-24.04-1

run_build Windows-64bit ghcr.io/arduino/crossbuild-windows-amd64:ubuntu-24.04-1
run_build Windows-arm64 ghcr.io/arduino/crossbuild-windows-arm64:ubuntu-24.04-1
