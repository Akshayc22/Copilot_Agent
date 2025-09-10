#!/bin/bash
# AI Copilot Flutter Agent - macOS Setup Script
# Usage: curl -fsSL https://your-org.com/setup-macos.sh | bash

set -e

ORG_REPO="${1:-https://github.com/your-org/ai-copilot-flutter-agent.git}"
WORKSPACE_PATH="$HOME/ai-copilot-workspace"

echo "🚀 AI Copilot Flutter Agent - macOS Setup"
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

# Check if Homebrew is installed
print_status "📦 Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_success "Homebrew installed successfully"
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_status "🔄 Updating Homebrew..."
brew update

# Install Flutter
print_status "📦 Installing Flutter SDK..."
if brew list flutter &>/dev/null; then
    print_success "Flutter already installed"
else
    brew install --cask flutter
    print_success "Flutter installed successfully"
fi

# Install Git
print_status "📦 Installing Git..."
if brew list git &>/dev/null; then
    print_success "Git already installed"
else
    brew install git
    print_success "Git installed successfully"
fi

# Install VS Code
print_status "📦 Installing Visual Studio Code..."
if brew list --cask visual-studio-code &>/dev/null; then
    print_success "VS Code already installed"
else
    brew install --cask visual-studio-code
    print_success "VS Code installed successfully"
fi

# Add Flutter to PATH
print_status "🔧 Configuring Flutter PATH..."
FLUTTER_PATH=$(brew --prefix)/bin/flutter
if ! echo $PATH | grep -q "$(dirname $FLUTTER_PATH)"; then
    echo "export PATH=\"\$PATH:$(dirname $FLUTTER_PATH)\"" >> ~/.zshrc
    echo "export PATH=\"\$PATH:$(dirname $FLUTTER_PATH)\"" >> ~/.bash_profile
    export PATH="$PATH:$(dirname $FLUTTER_PATH)"
fi

# Install VS Code extensions
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

# Clone the workspace
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
if flutter pub get; then
    print_success "Dependencies installed successfully"
else
    print_warning "Failed to install some dependencies"
fi

# Run Flutter doctor
print_status "🔍 Running Flutter doctor..."
flutter doctor

# Accept Android licenses if needed
if command -v flutter &> /dev/null; then
    print_status "📱 Accepting Android licenses..."
    flutter doctor --android-licenses || print_warning "Android licenses not accepted"
fi

# Create launch script
print_status "🚀 Creating launch script..."
cat > "$HOME/Desktop/AI Copilot Flutter.command" << EOF
#!/bin/bash
cd "$WORKSPACE_PATH"
code .
EOF

chmod +x "$HOME/Desktop/AI Copilot Flutter.command"
print_success "Desktop shortcut created"

# Final setup
print_status "🎉 Setup Complete!"
echo
print_success "📍 Workspace Location: $WORKSPACE_PATH"
print_success "🚀 To start developing:"
echo "   1. Double-click 'AI Copilot Flutter.command' on Desktop"
echo "   2. Or run: code '$WORKSPACE_PATH'"
echo "   3. Open Copilot Chat (Cmd+Shift+I)"
echo "   4. Use prompts from ai-prompts.txt"
echo "   5. Run: flutter run (mobile) or flutter run -d chrome (web)"
echo
print_status "📚 Next Steps:"
echo "   • Review README.md for detailed instructions"
echo "   • Check ENTERPRISE-DEPLOYMENT.md for organization setup"
echo "   • Start with sample prompts from ai-prompts.txt"

# Open VS Code with the workspace
if command -v code &> /dev/null; then
    print_status "🚀 Opening VS Code..."
    code "$WORKSPACE_PATH"
fi
