#!/bin/bash
#
# install-opa.sh - Install OPA CLI for testing Rego rules
#
# This script installs the Open Policy Agent (OPA) CLI tool for running Rego tests.
# Designed for both local development and CI/CD environments.
#
# Usage:
#   ./install-opa.sh [version]
#
# Examples:
#   ./install-opa.sh          # Install latest version
#   ./install-opa.sh 0.59.0   # Install specific version

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default version (latest)
OPA_VERSION="${1:-latest}"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo -e "${YELLOW}Warning: Unknown architecture $ARCH, trying amd64${NC}"
        ARCH="amd64"
        ;;
esac

# Map OS names
case "$OS" in
    darwin)
        OS="darwin"
        ;;
    linux)
        OS="linux"
        ;;
    mingw*|msys*|cygwin*)
        OS="windows"
        ;;
    *)
        echo -e "${YELLOW}Warning: Unknown OS $OS, trying linux${NC}"
        OS="linux"
        ;;
esac

echo -e "${BLUE}Installing OPA CLI${NC}"
echo -e "${BLUE}==================${NC}"
echo ""
echo -e "${BLUE}OS:${NC} $OS"
echo -e "${BLUE}Architecture:${NC} $ARCH"
echo -e "${BLUE}Version:${NC} $OPA_VERSION"
echo ""

# Check if OPA is already installed
if command -v opa &> /dev/null; then
    INSTALLED_VERSION=$(opa version | head -n 1 | awk '{print $2}')
    echo -e "${GREEN}OPA is already installed: $INSTALLED_VERSION${NC}"

    if [ "$OPA_VERSION" != "latest" ] && [ "$INSTALLED_VERSION" != "$OPA_VERSION" ]; then
        echo -e "${YELLOW}Requested version $OPA_VERSION differs from installed $INSTALLED_VERSION${NC}"
        read -p "Reinstall? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Keeping existing installation"
            exit 0
        fi
    else
        echo "Use --force to reinstall"
        exit 0
    fi
fi

# Determine download URL
if [ "$OPA_VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://openpolicyagent.org/downloads/latest/opa_${OS}_${ARCH}"
else
    DOWNLOAD_URL="https://openpolicyagent.org/downloads/v${OPA_VERSION}/opa_${OS}_${ARCH}"
fi

echo -e "${BLUE}Downloading from:${NC} $DOWNLOAD_URL"
echo ""

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download OPA
if command -v curl &> /dev/null; then
    curl -L -o "$TEMP_DIR/opa" "$DOWNLOAD_URL"
elif command -v wget &> /dev/null; then
    wget -O "$TEMP_DIR/opa" "$DOWNLOAD_URL"
else
    echo -e "${YELLOW}Error: Neither curl nor wget found. Please install one of them.${NC}"
    exit 1
fi

# Make executable
chmod +x "$TEMP_DIR/opa"

# Verify it works
if ! "$TEMP_DIR/opa" version &> /dev/null; then
    echo -e "${YELLOW}Error: Downloaded OPA binary doesn't work. Check OS/architecture.${NC}"
    exit 1
fi

# Determine install location
INSTALL_DIR="/usr/local/bin"

# Check if we can write to /usr/local/bin
if [ ! -w "$INSTALL_DIR" ]; then
    # Try user local bin
    INSTALL_DIR="$HOME/.local/bin"

    # Create if doesn't exist
    mkdir -p "$INSTALL_DIR"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo -e "${YELLOW}Adding $INSTALL_DIR to PATH${NC}"
        echo ""
        echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
    fi
fi

# Move to install directory
echo -e "${BLUE}Installing to:${NC} $INSTALL_DIR"
mv "$TEMP_DIR/opa" "$INSTALL_DIR/opa"

# Verify installation
if command -v opa &> /dev/null; then
    INSTALLED_VERSION=$(opa version)
    echo ""
    echo -e "${GREEN}✓ OPA installed successfully!${NC}"
    echo ""
    echo "$INSTALLED_VERSION"
    echo ""
    echo "Try it out:"
    echo "  opa test --help"
else
    echo -e "${YELLOW}OPA installed to $INSTALL_DIR/opa but not found in PATH${NC}"
    echo "Add to PATH:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    exit 1
fi
