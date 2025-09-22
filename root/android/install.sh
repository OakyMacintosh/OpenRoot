#!/system/bin/sh

# Configuration
PACKAGE_NAME="me.openroot"
ROOTD_DIR="/data/data/$PACKAGE_NAME/rootd"
ROOTD_BIN="$ROOTD_DIR/bin"
ROOTD_LIB="$ROOTD_DIR/lib"
ROOTD_CONFIG="$ROOTD_DIR/etc"
ROOTD_CACHE="$ROOTD_DIR/cache"

# Ensure we're running as the correct user
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root or with su permissions"
    exit 1
fi

# Create directory structure
create_directories() {
    mkdir -p "$ROOTD_DIR"
    mkdir -p "$ROOTD_BIN"
    mkdir -p "$ROOTD_LIB"
    mkdir -p "$ROOTD_CONFIG"
    mkdir -p "$ROOTD_CACHE"

    # Set correct permissions
    chown -R $PACKAGE_NAME:$PACKAGE_NAME "$ROOTD_DIR"
    chmod -R 700 "$ROOTD_DIR"
}

# Copy rootd binary and libraries
install_rootd() {
    # Copy the rootd binary
    cp "/data/app/$PACKAGE_NAME*/lib/*/librootd.so" "$ROOTD_BIN/rootd"
    chmod 700 "$ROOTD_BIN/rootd"

    # Copy configuration
    cp "/data/app/$PACKAGE_NAME*/assets/rootd.conf" "$ROOTD_CONFIG/"
    chmod 600 "$ROOTD_CONFIG/rootd.conf"
}

# Setup SELinux context if applicable
setup_selinux() {
    if command -v setenforce >/dev/null 2>&1; then
        chcon -R u:object_r:app_data_file:s0 "$ROOTD_DIR"
    fi
}

# Main installation process
echo "Starting OpenRoot installation..."

echo "Creating directory structure..."
create_directories

echo "Installing rootd..."
install_rootd

echo "Setting up SELinux context..."
setup_selinux

echo "Installation complete!"

# Start the rootd service
am startservice me.openroot/.RootdService