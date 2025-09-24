#!/bin# Set up correct project structure
echo "Setting up project structure..."

# Create source directories if they don't exist
mkdir -p "$SCRIPT_DIR/src/main/java/me/openroot"
mkdir -p "$SCRIPT_DIR/cpp"
mkdir -p "$SCRIPT_DIR/assets"
mkdir -p "$SCRIPT_DIR/res"

# Move files to correct locations
mv -n "$SCRIPT_DIR/RootdService.java" "$SCRIPT_DIR/src/main/java/me/openroot/" 2>/dev/null || true
mv -n "$SCRIPT_DIR/install.sh" "$SCRIPT_DIR/assets/" 2>/dev/null || true

# Download json dependency if needed
if [ ! -f "$PROJECT_ROOT/include/json/json.hpp" ]; then
    echo "Fetching json library..."
    mkdir -p "$PROJECT_ROOT/include/json"
    curl -L https://github.com/nlohmann/json/releases/download/v3.11.2/json.hpp -o "$PROJECT_ROOT/include/json/json.hpp"
    if [ ! -f "$PROJECT_ROOT/include/json/json.hpp" ]; then
        echo "Error: Failed to fetch json library"
        exit 1
    fi
fi

# Initialize Gradle if needed
if [ ! -f "gradlew" ]; then
    echo "Downloading Gradle wrapper..."
    gradle wrapper
fi

# Make gradlew executable
chmod +x gradlewfiguration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Setup correct project structure
echo "Setting up project structure..."

# Create source directories if they don't exist
mkdir -p "$SCRIPT_DIR/src/main/java/me/openroot"
mkdir -p "$SCRIPT_DIR/cpp"
mkdir -p "$SCRIPT_DIR/assets"
mkdir -p "$SCRIPT_DIR/res"

# Move files to correct locations
mv -n "$SCRIPT_DIR/RootdService.java" "$SCRIPT_DIR/src/main/java/me/openroot/" 2>/dev/null || true
mv -n "$SCRIPT_DIR/install.sh" "$SCRIPT_DIR/assets/" 2>/dev/null || truen/bash

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ANDROID_PROJECT_DIR="$PROJECT_ROOT/droid-chan"
ROOTD_LIB_DIR="$ANDROID_PROJECT_DIR/app/src/main/jniLibs/arm64-v8a"

# Check for Android SDK
if [ -z "$ANDROID_HOME" ]; then
    if [ -d "$HOME/Android/Sdk" ]; then
        ANDROID_HOME="$HOME/Android/Sdk"
    else
        echo "Error: ANDROID_HOME not set and could not be found"
        exit 1
    fi
fi

# Check for NDK
NDK_HOME="$ANDROID_HOME/ndk/26.2.11394342"
if [ ! -d "$NDK_HOME" ]; then
    echo "Error: NDK not found at $NDK_HOME"
    exit 1
fi

# Create directories if they don't exist
echo "Creating project structure..."
mkdir -p "$ROOTD_LIB_DIR"


# Build the APK using Gradle
echo "Building APK with Gradle..."
cd "$ANDROID_PROJECT_DIR" || exit 1

# Check if gradlew exists, if not download it
if [ ! -f "gradlew" ]; then
    echo "Downloading Gradle wrapper..."
    gradle wrapper
fi

# Make gradlew executable
chmod +x gradlew

# Build debug APK
./gradlew assembleDebug || exit 1

echo "Build complete! APK available at app/build/outputs/apk/debug/app-debug.apk"

# Verify librootd.so was built
if [ ! -f "$PROJECT_ROOT/$BUILD_DIR/apk/lib/arm64-v8a/librootd.so" ]; then
    echo "Error: Failed to build librootd.so"
    exit 1
fi

# Build APK with Gradle
echo "Building APK with Gradle..."
./gradlew assembleDebug || { echo "Gradle build failed"; exit 1; }

# Show where to find the APK
echo "Build complete! APK available at build/outputs/apk/debug/app-debug.apk"

if [ ! -f "$PROJECT_ROOT/$BUILD_DIR/openroot.unsigned.apk" ]; then
    echo "Error: Failed to create APK"
    exit 1
fi

cd "$SCRIPT_DIR" || exit 1

# Sign APK
echo "Signing APK..."

# Use debug keystore for development builds
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
mkdir -p "$(dirname "$DEBUG_KEYSTORE")"

# Create debug keystore if it doesn't exist
if [ ! -f "$DEBUG_KEYSTORE" ]; then
    echo "Creating debug keystore..."
    keytool -genkeypair -v \
        -keystore "$DEBUG_KEYSTORE" \
        -storepass android \
        -alias androiddebugkey \
        -keypass android \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=Android Debug,O=Android,C=US"
fi

# Sign the APK using apksigner (newer recommended approach)
"$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION/apksigner" sign \
    --ks "$DEBUG_KEYSTORE" \
    --ks-key-alias androiddebugkey \
    --ks-pass pass:android \
    --key-pass pass:android \
    --out "$PROJECT_ROOT/$BUILD_DIR/openroot.apk" \
    "$PROJECT_ROOT/$BUILD_DIR/openroot.unsigned.apk"

if [ ! -f "$PROJECT_ROOT/$BUILD_DIR/openroot.apk" ]; then
    echo "Error: Failed to sign APK"
    exit 1
fi

echo "Build complete! APK available at $PROJECT_ROOT/$BUILD_DIR/openroot.apk"
