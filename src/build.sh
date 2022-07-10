#!/bin/bash

# Get current working directory
BASEDIR=$(dirname "$0")

if [ "$BASEDIR" == "." ]; then
   BASEDIR=$(pwd)
fi

# Check if the script has been executed using sudo
#if [ ! "$EUID" == 0 ]; then
#    echo "You must run this program as root or using sudo!"
#    exit
#fi

# Check if the script has been executed in macOS
if ! [[ "$OSTYPE" == "darwin"* ]]; then
    echo "You must run this program from macOS with Xcode!"
    exit
fi

# Set application constants
BUILD_DIR="$BASEDIR/build"
BOOT_MANAGER_DIR="$BASEDIR/boot_manager"

# Delete the previous build
rm -rf "$BUILD_DIR/" >/dev/null 2>&1

# Create a macOS build folder
mkdir -p "$BUILD_DIR/"

# Compile Boot Manager app
#xcode-select --install
#xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -project "$BOOT_MANAGER_DIR/Boot Manager.xcodeproj" -alltargets -configuration Release
#xcode-select --switch /Library/Developer/CommandLineTools

cp -r "$BOOT_MANAGER_DIR/build/Release/Boot Manager.app" "$BUILD_DIR/"

# Compile Packages
packagesbuild -v "$BASEDIR/boot_manager.pkgproj"
packagesbuild -v "$BASEDIR/sata3.pkgproj"
packagesbuild -v "$BASEDIR/distribution.pkgproj"

# Clean rules for build
rm -rf "$BOOT_MANAGER_DIR/build/"
rm -rf "$BUILD_DIR/3rd-Party SATA AHCI Driver.pkg"
rm -rf "$BUILD_DIR/Boot Manager Application.pkg"
