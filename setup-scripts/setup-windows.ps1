# AI Copilot Flutter Agent - Windows Setup Script
# Run as Administrator in PowerShell
# Usage: irm https://your-org.com/setup-windows.ps1 | iex

param(
    [string]$OrgRepo = "https://github.com/your-org/ai-copilot-flutter-agent.git",
    [string]$WorkspacePath = "$env:USERPROFILE\ai-copilot-workspace"
)

Write-Host "🚀 AI Copilot Flutter Agent - Windows Setup" -ForegroundColor Cyan
Write-Host "Organization Repository: $OrgRepo" -ForegroundColor Green

# Function to check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host "⚠️  Please run this script as Administrator" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing Chocolatey package manager..." -ForegroundColor Yellow
try {
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    Write-Host "✅ Chocolatey installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install Chocolatey: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing Flutter SDK..." -ForegroundColor Yellow
try {
    choco install flutter -y
    Write-Host "✅ Flutter installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install Flutter: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing Git..." -ForegroundColor Yellow
try {
    choco install git -y
    Write-Host "✅ Git installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install Git: $_" -ForegroundColor Red
}

Write-Host "📦 Installing VS Code..." -ForegroundColor Yellow
try {
    choco install vscode -y
    Write-Host "✅ VS Code installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install VS Code: $_" -ForegroundColor Red
}

# Refresh environment variables
Write-Host "🔄 Refreshing environment variables..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "🔌 Installing VS Code extensions..." -ForegroundColor Yellow
$extensions = @(
    "dart-code.dart-code",
    "dart-code.flutter",
    "github.copilot",
    "github.copilot-chat"
)

foreach ($extension in $extensions) {
    try {
        Start-Process -FilePath "code" -ArgumentList "--install-extension $extension" -Wait -NoNewWindow
        Write-Host "✅ Installed extension: $extension" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Failed to install extension: $extension" -ForegroundColor Yellow
    }
}

Write-Host "📥 Cloning AI Copilot workspace..." -ForegroundColor Yellow
try {
    if (Test-Path $WorkspacePath) {
        Remove-Item -Path $WorkspacePath -Recurse -Force
    }
    git clone $OrgRepo $WorkspacePath
    Set-Location $WorkspacePath
    Write-Host "✅ Workspace cloned successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to clone workspace: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing Flutter dependencies..." -ForegroundColor Yellow
try {
    flutter pub get
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install dependencies: $_" -ForegroundColor Red
}

Write-Host "🔍 Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor

Write-Host "🎉 Setup Complete!" -ForegroundColor Cyan
Write-Host "📍 Workspace Location: $WorkspacePath" -ForegroundColor Green
Write-Host "🚀 To start developing:" -ForegroundColor Green
Write-Host "   1. Open VS Code: code '$WorkspacePath'" -ForegroundColor White
Write-Host "   2. Open Copilot Chat (Ctrl+Shift+I)" -ForegroundColor White
Write-Host "   3. Use prompts from ai-prompts.txt" -ForegroundColor White
Write-Host "   4. Run: flutter run (for mobile) or flutter run -d chrome (for web)" -ForegroundColor White

# Create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\AI Copilot Flutter.lnk")
$Shortcut.TargetPath = "code"
$Shortcut.Arguments = "`"$WorkspacePath`""
$Shortcut.WorkingDirectory = $WorkspacePath
$Shortcut.IconLocation = "code.exe,0"
$Shortcut.Description = "AI Copilot Flutter Development Workspace"
$Shortcut.Save()

Write-Host "🖱️  Desktop shortcut created" -ForegroundColor Green
