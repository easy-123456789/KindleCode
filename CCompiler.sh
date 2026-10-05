#!/bin/bash
# Entware Installation Script for Kindle
# This script automates the installation of Entware on a jailbroken Kindle
# Usage: ./install-entware-kindle.sh [architecture]
# Supported architectures: armv7, armv5

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENTWARE_INSTALL_PATH="/opt"
ARCHITECTURE="${1:-armv7}"  # Default to armv7
INSTALL_GCC="${2:-false}"   # Optional: install GCC

# Functions
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

check_requirements() {
    print_info "Checking requirements..."
    
    # Check if running on Kindle (optional, can be commented out)
    if ! uname -a | grep -qi "kindle\|amazon"; then
        print_info "Not detected as Kindle, but continuing anyway..."
    fi
    
    # Check if wget is available
    if ! command -v wget &> /dev/null; then
        print_error "wget is required but not installed"
        exit 1
    fi
    
    print_success "Requirements check passed"
}

validate_architecture() {
    print_info "Validating architecture: $ARCHITECTURE"
    
    case "$ARCHITECTURE" in
        armv7)
            INSTALLER_URL="https://bin.entware.net/armv7sf-k3.2/installer/generic.sh"
            ;;
        armv5)
            INSTALLER_URL="https://bin.entware.net/armv5sf-k3.2/installer/generic.sh"
            ;;
        *)
            print_error "Unsupported architecture: $ARCHITECTURE"
            echo "Supported: armv7, armv5"
            exit 1
            ;;
    esac
    
    print_success "Architecture validated: $ARCHITECTURE"
}

check_disk_space() {
    print_info "Checking available disk space..."
    
    AVAILABLE_SPACE=$(df /opt 2>/dev/null | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=10240  # 10MB in KB
    
    if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
        print_error "Insufficient disk space. Required: 10MB, Available: $(( AVAILABLE_SPACE / 1024 ))MB"
        exit 1
    fi
    
    print_success "Sufficient disk space available"
}

install_entware() {
    print_info "Starting Entware installation from: $INSTALLER_URL"
    
    if wget "$INSTALLER_URL" -O - | sh; then
        print_success "Entware installation completed successfully"
    else
        print_error "Entware installation failed"
        exit 1
    fi
}

configure_path() {
    print_info "Configuring PATH environment variable..."
    
    PROFILE_FILE="/etc/profile.local"
    KINDLE_PROFILE="$HOME/.profile"
    
    # Try to add to /etc/profile.local if it exists
    if [ -w "$PROFILE_FILE" ]; then
        if ! grep -q "/opt/bin" "$PROFILE_FILE"; then
            {
                echo ""
                echo "# Entware PATH configuration"
                echo "export PATH=/opt/bin:/opt/sbin:\$PATH"
            } >> "$PROFILE_FILE"
            print_success "Added Entware PATH to $PROFILE_FILE"
        fi
    # Otherwise add to user's .profile
    elif [ -w "$KINDLE_PROFILE" ] || [ ! -e "$KINDLE_PROFILE" ]; then
        if ! grep -q "/opt/bin" "$KINDLE_PROFILE" 2>/dev/null; then
            {
                echo ""
                echo "# Entware PATH configuration"
                echo "export PATH=/opt/bin:/opt/sbin:\$PATH"
            } >> "$KINDLE_PROFILE"
            print_success "Added Entware PATH to $KINDLE_PROFILE"
        fi
    fi
}

initialize_entware() {
    print_info "Initializing Entware package manager..."
    
    if [ -x "/opt/bin/opkg" ]; then
        print_info "Updating package list..."
        if /opt/bin/opkg update; then
            print_success "Package list updated"
        else
            print_error "Failed to update package list"
            exit 1
        fi
        
        print_info "Upgrading existing packages..."
        if /opt/bin/opkg upgrade; then
            print_success "Packages upgraded"
        else
            print_error "Failed to upgrade packages (non-critical)"
        fi
    else
        print_error "opkg not found at /opt/bin/opkg"
        exit 1
    fi
}

verify_installation() {
    print_info "Verifying Entware installation..."
    
    if [ -d "$ENTWARE_INSTALL_PATH" ] && [ -x "$ENTWARE_INSTALL_PATH/bin/opkg" ]; then
        VERSION=$("$ENTWARE_INSTALL_PATH/bin/opkg" --version 2>/dev/null || echo "unknown")
        print_success "Entware is installed and functional (opkg version: $VERSION)"
        return 0
    else
        print_error "Entware verification failed"
        return 1
    fi
}

install_gcc() {
    print_info "Installing GCC, Make, and binutils..."
    
    if /opt/bin/opkg install gcc make binutils; then
        print_success "GCC, Make, and binutils installed successfully"
        echo ""
        echo "You can now compile C code on Kindle:"
        echo "  gcc hello.c -o hello && ./hello"
    else
        print_error "Failed to install GCC and tools"
        exit 1
    fi
}

main() {
    echo "╔════════════════════════════════════════╗"
    echo "║  Entware Installation Script for Kindle║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    check_requirements
    validate_architecture
    check_disk_space
    install_entware
    configure_path
    initialize_entware
    verify_installation
    
    # Install GCC if requested
    if [ "$INSTALL_GCC" = "true" ] || [ "$INSTALL_GCC" = "gcc" ]; then
        echo ""
        install_gcc
    fi
    
    echo ""
    print_success "Entware installation completed!"
    echo ""
    echo "Next steps:"
    echo "  1. Reload your shell profile: source /etc/profile.local"
    echo "  2. Install packages: opkg install <package-name>"
    echo "  3. List available packages: opkg list-available"
    echo ""
    echo "To install GCC on Kindle, run:"
    echo "  ./install-entware-kindle.sh armv7 gcc"
    echo ""
    echo "For more information, visit: https://github.com/Entware/Entware"
}

# Run main function
main "$@"
