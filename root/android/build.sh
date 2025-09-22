#!/bin/bash

# Configuration
PACKAGE="me.openroot"
VERSION_CODE="1"
VERSION_NAME="1.0"
BUILD_DIR="build/android"

# Ensure build directory exists
mkdir -p "$BUILD_DIR"

# Build rootd for Android
echo "Building rootd for Android..."
$NDK/build/tools/make-standalone-toolchain.sh --arch=arm64 --install-dir=$BUILD_DIR/toolchain
export PATH=$BUILD_DIR/toolchain/bin:$PATH
cd rootd && make android && cd ..

# Create APK structure
echo "Creating APK structure..."
mkdir -p "$BUILD_DIR/apk"
mkdir -p "$BUILD_DIR/apk/lib/arm64-v8a"

# Copy files
cp root/android/AndroidManifest.xml "$BUILD_DIR/apk/"
cp root/android/install.sh "$BUILD_DIR/apk/assets/"
cp rootd/build/android/librootd.so "$BUILD_DIR/apk/lib/arm64-v8a/"

# Build APK
echo "Building APK..."
$ANDROID_SDK/build-tools/latest/aapt package -f -M "$BUILD_DIR/apk/AndroidManifest.xml" \
    -I "$ANDROID_SDK/platforms/android-31/android.jar" \
    -F "$BUILD_DIR/openroot.apk" \
    "$BUILD_DIR/apk"

# Sign APK
echo "Signing APK..."
jarsigner -keystore ~/.android/debug.keystore \
    -storepass android \
    "$BUILD_DIR/openroot.apk" \
    androiddebugkey

echo "Build complete! APK available at $BUILD_DIR/openroot.apk"