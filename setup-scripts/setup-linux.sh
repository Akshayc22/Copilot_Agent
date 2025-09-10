#!/bin/bash
# AI Copilot Flutter Agent - Linux Setup Script
# Supports Ubuntu 18.04+, Debian, CentOS, Fedora
# Usage: curl -fsSL https://your-org.com/setup-linux.sh | bash

set -e

ORG_REPO="${1:-https://github.com/your-org/ai-copilot-flutter-agent.git}"
WORKSPACE_PATH="$HOME/ai-copilot-workspace"

echo "🐧 AI Copilot Flutter Agent - Linux Setup"
echo "Organization Repository: $ORG_REPO"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Detect Linux distribution
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}

# Install packages based on distribution
install_packages() {
    detect_os
    print_status "📦 Detected OS: $OS"
    
    case $OS in
        "Ubuntu"*|"Debian"*)
            print_status "Using APT package manager..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install -y curl git unzip xz-utils zip libglu1-mesa snapd wget gpg
            install_vscode_apt
            ;;
        "CentOS"*|"Red Hat"*|"Fedora"*)
            print_status "Using YUM/DNF package manager..."
            if command -v dnf &> /dev/null; then
                sudo dnf update -y
                sudo dnf install -y curl git unzip xz zip mesa-libGLU snapd wget gpg
            else
                sudo yum update -y
                sudo yum install -y curl git unzip xz zip mesa-libGLU snapd wget gpg
            fi
            install_vscode_rpm
            ;;
        *)
            print_warning "Unsupported Linux distribution. Attempting generic installation..."
            ;;
    esac
}

# Install VS Code for APT-based systems
install_vscode_apt() {
    print_status "📦 Installing VS Code (APT)..."
    
    # Add Microsoft GPG key and repository
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    
    # Update and install
    sudo apt update
    sudo apt install -y code
    
    print_success "VS Code installed successfully"
}

# Install VS Code for RPM-based systems
install_vscode_rpm() {
    print_status "📦 Installing VS Code (RPM)..."
    
    # Add Microsoft repository
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    
    # Install based on package manager
    if command -v dnf &> /dev/null; then
        sudo dnf check-update
        sudo dnf install -y code
    else
        sudo yum check-update
        sudo yum install -y code
    fi
    
    print_success "VS Code installed successfully"
}

# Install Flutter SDK
install_flutter() {
    print_status "📦 Installing Flutter SDK..."
    
    # Remove existing installation
    if [ -d "$HOME/flutter" ]; then
        rm -rf "$HOME/flutter"
    fi
    
    # Clone Flutter repository
    cd "$HOME"
    git clone https://github.com/flutter/flutter.git -b stable
    
    # Add to PATH
    if ! grep -q "flutter/bin" ~/.bashrc; then
        echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
    fi
    
    if ! grep -q "flutter/bin" ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
    fi
    
    # Export for current session
    export PATH="$PATH:$HOME/flutter/bin"
    
    print_success "Flutter installed successfully"
}

# Install VS Code extensions
install_extensions() {
    print_status "🔌 Installing VS Code extensions..."
    
    extensions=(
        "dart-code.dart-code"
        "dart-code.flutter"
        "github.copilot"
        "github.copilot-chat"
    )
    
    for extension in "${extensions[@]}"; do
        if code --install-extension "$extension" --force; then
            print_success "Installed extension: $extension"
        else
            print_warning "Failed to install extension: $extension"
        fi
    done
}

# Main installation process
main() {
    print_status "🚀 Starting AI Copilot Flutter Agent setup for Linux..."
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
    fi
    
    # Install system packages
    install_packages
    
    # Install Flutter
    install_flutter
    
    # Install VS Code extensions
    install_extensions
    
    # Clone workspace
    print_status "📥 Cloning AI Copilot workspace..."
    if [ -d "$WORKSPACE_PATH" ]; then
        rm -rf "$WORKSPACE_PATH"
    fi
    
    if git clone "$ORG_REPO" "$WORKSPACE_PATH"; then
        print_success "Workspace cloned successfully"
        cd "$WORKSPACE_PATH"
    else
        print_error "Failed to clone workspace"
    fi
    
    # Install Flutter dependencies
    print_status "📦 Installing Flutter dependencies..."
    source ~/.bashrc
    if $HOME/flutter/bin/flutter pub get; then
        print_success "Dependencies installed successfully"
    else
        print_warning "Failed to install some dependencies"
    fi
    
    # Run Flutter doctor
    print_status "🔍 Running Flutter doctor..."
    $HOME/flutter/bin/flutter doctor
    
    # Accept Android licenses
    print_status "📱 Setting up Android development..."
    $HOME/flutter/bin/flutter doctor --android-licenses || print_warning "Android licenses not accepted"
    
    # Create desktop shortcut
    create_desktop_shortcut
    
    # Final setup message
    print_status "🎉 Setup Complete!"
    echo
    print_success "📍 Workspace Location: $WORKSPACE_PATH"
    print_success "🚀 To start developing:"
    echo "   1. Source your shell: source ~/.bashrc"
    echo "   2. Open VS Code: code '$WORKSPACE_PATH'"
    echo "   3. Open Copilot Chat (Ctrl+Shift+I)"
    echo "   4. Use prompts from ai-prompts.txt"
    echo "   5. Run: flutter run (mobile) or flutter run -d chrome (web)"
    echo
    print_status "📚 Next Steps:"
    echo "   • Review README.md for detailed instructions"
    echo "   • Check ENTERPRISE-DEPLOYMENT.md for organization setup"
    echo "   • Start with sample prompts from ai-prompts.txt"
    
    # Open VS Code
    print_status "🚀 Opening VS Code..."
    nohup code "$WORKSPACE_PATH" > /dev/null 2>&1 &
}

# Create desktop shortcut
create_desktop_shortcut() {
    print_status "🖥️  Creating desktop shortcut..."
    
    DESKTOP_DIR="$HOME/Desktop"
    if [ ! -d "$DESKTOP_DIR" ]; then
        DESKTOP_DIR="$HOME/Рабочий стол" # Russian
        if [ ! -d "$DESKTOP_DIR" ]; then
            DESKTOP_DIR="$HOME/Bureau" # French
            if [ ! -d "$DESKTOP_DIR" ]; then
                mkdir -p "$HOME/Desktop"
                DESKTOP_DIR="$HOME/Desktop"
            fi
        fi
    fi
    
    cat > "$DESKTOP_DIR/AI-Copilot-Flutter.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=AI Copilot Flutter
Comment=AI-powered Flutter development workspace
Exec=code "$WORKSPACE_PATH"
Icon=code
Terminal=false
Categories=Development;
EOF
    
    chmod +x "$DESKTOP_DIR/AI-Copilot-Flutter.desktop"
    print_success "Desktop shortcut created"
}

# Run main function
main "$@"
