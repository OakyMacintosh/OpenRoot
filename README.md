# OpenRoot

OpenRoot is an innovative root emulation layer that provides root-like capabilities without requiring actual root access or bootloader unlocking. It works across Unix-like systems and Android devices, offering a safe way to execute privileged operations through a controlled emulation environment.

## Building from Source

### Prerequisites

- CMake 3.15+
- C++17 compatible compiler
- Android NDK (for Android build)
- vcpkg (for dependency management)

### Build Steps

```bash
# Configure with vcpkg
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=[path_to_vcpkg]/scripts/buildsystems/vcpkg.cmake

# Build
cmake --build build

# Install
sudo cmake --install build
```

## Credits

OpenRoot is inspired by various root solutions and Unix system designs:
- [Magisk](https://github.com/topjohnwu/Magisk)
- [KernelSU](https://github.com/tiann/KernelSU)
- [Wine](https://www.winehq.org/)
- [Darling](https://www.darlinghq.org/)
