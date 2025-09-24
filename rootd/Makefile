# Path to your NDK
ANDROID_NDK := $(HOME)/Android/Sdk/ndk/26.2.11394342
TOOLCHAIN   := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin

# Target triple for 64-bit ARM, API 21+
TARGET      := aarch64-linux-android21

# Output dir
OUTDIR      := build/android

# Rule to build for Android
android:
	mkdir -p $(OUTDIR)
	$(TOOLCHAIN)/$(TARGET)-clang++ -fPIC -shared \
	    -Iinclude \
	    rootd.cc -o $(OUTDIR)/librootd.so

CXX := gcc
CFLAGS := -Wall -std=c++17 -static
OUT := rootd
SRCS := rootd.cc
JAVA := javac
JSRCS := UnixRootdJavaService.java
JAR := rootdnix.jar

common:
	mkdir -p build/common
	$(CXX) $(CFLAGS) -Iinclude -c $(SRCS) -o build/common/rootd]
	$(JAVAC) $(JSRCS) -d build/common/common
	jar cf $(JAR) -C build/common common.jar
