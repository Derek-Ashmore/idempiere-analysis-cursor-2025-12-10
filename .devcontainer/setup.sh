#!/bin/bash
set -e

echo "=========================================="
echo "Setting up Claude Flow Codespace..."
echo "=========================================="

# Set workspace directory (use current directory if /workspace doesn't exist)
WORKSPACE_DIR="${WORKSPACE_DIR:-/workspaces/$(basename $(pwd))}"
if [ ! -d "$WORKSPACE_DIR" ]; then
    WORKSPACE_DIR="/workspace"
fi
if [ ! -d "$WORKSPACE_DIR" ]; then
    WORKSPACE_DIR="$(pwd)"
fi

echo "Workspace directory: $WORKSPACE_DIR"

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install additional dependencies
echo "Installing additional dependencies..."
sudo apt-get install -y curl wget git jq unzip

# Wait for Node.js and npm to be available
echo "=========================================="
echo "Checking Node.js and npm..."
echo "=========================================="
# Wait up to 30 seconds for npm to be available
for i in {1..30}; do
    if command -v npm &> /dev/null; then
        echo "✓ npm found"
        npm --version
        break
    fi
    echo "Waiting for npm... ($i/30)"
    sleep 1
done

if ! command -v npm &> /dev/null; then
    echo "Error: npm not found after waiting. Please check Node.js installation."
    exit 1
fi

# Ensure npm global bin is in PATH
export PATH="$PATH:$HOME/.npm-global/bin:/usr/local/share/npm-global/bin"
npm config set prefix "${NPM_PREFIX:-/usr/local/share/npm-global}"

# Install Claude Code
echo "=========================================="
echo "Installing Claude Code..."
echo "=========================================="
npm install -g @anthropic-ai/claude-code || {
    echo "Error: Failed to install Claude Code"
    echo "Attempting with sudo..."
    sudo npm install -g @anthropic-ai/claude-code --unsafe-perm
}

# Verify installation
if command -v claude-code &> /dev/null; then
    echo "✓ Claude Code installed successfully"
    claude-code --version 2>/dev/null || echo "  (version: installed)"
else
    echo "Warning: claude-code command not found in PATH"
    echo "Checking installation location..."
    npm list -g @anthropic-ai/claude-code || true
fi

# Also install Python Anthropic SDK for programmatic access
echo "Installing Anthropic Python SDK..."
pip install anthropic
echo "Anthropic Python SDK installed successfully"

# Install Claude-Flow as a Claude Code plugin
echo "=========================================="
echo "Installing Claude-Flow Plugin..."
echo "=========================================="

# Create a helper script to install the plugin
cat > /tmp/install-claude-flow.sh << 'PLUGIN_EOF'
#!/bin/bash
# This script installs the Claude-Flow plugin for Claude Code

# Check if Claude Code is available
if ! command -v claude-code &> /dev/null; then
    echo "Error: claude-code not found. Please install it first."
    exit 1
fi

# Install the plugin by sending the command to Claude Code
# Note: This attempts to install the plugin programmatically
echo "Installing Claude-Flow plugin..."
echo "/plugin ruvnet/claude-flow" | claude-code --dangerously-skip-permissions 2>/dev/null || {
    echo ""
    echo "Note: Automatic plugin installation may not be supported."
    echo "To install Claude-Flow manually, run:"
    echo "  claude-code --dangerously-skip-permissions"
    echo "Then type: /plugin ruvnet/claude-flow"
    echo ""
}
PLUGIN_EOF

chmod +x /tmp/install-claude-flow.sh

# Attempt to install the plugin
/tmp/install-claude-flow.sh || {
    echo ""
    echo "Claude-Flow plugin installation will need to be completed manually."
    echo "After the Codespace starts, open Claude Code and run:"
    echo "  claude-code"
    echo "Then in the interactive prompt, type:"
    echo "  /plugin ruvnet/claude-flow"
    echo ""
}

# Clean up
rm -f /tmp/install-claude-flow.sh

echo "Claude-Flow plugin setup complete!"

# Configure shell aliases for convenience
echo "=========================================="
echo "Configuring shell aliases..."
echo "=========================================="

# Add npm global bin to PATH in bashrc
if ! grep -q "npm-global/bin" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Add npm global packages to PATH" >> ~/.bashrc
    echo 'export PATH="$PATH:$HOME/.npm-global/bin:/usr/local/share/npm-global/bin"' >> ~/.bashrc
    echo "PATH updated in ~/.bashrc"
fi

# Add alias to bashrc
if ! grep -q "alias claude=" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Claude Code alias with permissions pre-approved" >> ~/.bashrc
    echo "alias claude='claude-code --dangerously-skip-permissions'" >> ~/.bashrc
    echo "Claude alias added to ~/.bashrc"
fi

# Add alias to bash_profile if it exists
if [ -f ~/.bash_profile ]; then
    if ! grep -q "alias claude=" ~/.bash_profile 2>/dev/null; then
        echo "" >> ~/.bash_profile
        echo "# Claude Code alias with permissions pre-approved" >> ~/.bash_profile
        echo "alias claude='claude-code --dangerously-skip-permissions'" >> ~/.bash_profile
        echo "Claude alias added to ~/.bash_profile"
    fi
fi

# Source the alias for current session
alias claude='claude-code --dangerously-skip-permissions'

echo "Alias configured: 'claude' now runs 'claude-code --dangerously-skip-permissions'"

# Verify Azure CLI installation
echo "=========================================="
echo "Verifying Azure CLI..."
echo "=========================================="
if command -v az &> /dev/null; then
    az version
    echo "Azure CLI is installed and ready"
else
    echo "Warning: Azure CLI not found. Installing manually..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# Verify AWS CLI installation
echo "=========================================="
echo "Verifying AWS CLI..."
echo "=========================================="
if command -v aws &> /dev/null; then
    aws --version
    echo "AWS CLI is installed and ready"
else
    echo "Warning: AWS CLI not found. Installing manually..."
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    cd "$WORKSPACE_DIR"
fi

# Note: AWS CLI credential configuration moved to configure-secrets.sh
# which runs via postStartCommand when secrets are available
echo "AWS CLI installed. Credentials will be configured when secrets are available."

# Create helper scripts
echo "=========================================="
echo "Creating helper scripts..."
echo "=========================================="

# Claude-Flow plugin installation helper
cat > "$WORKSPACE_DIR/install-claude-flow.sh" << 'EOF'
#!/bin/bash
echo "=========================================="
echo "Installing Claude-Flow Plugin"
echo "=========================================="
echo ""
echo "This will launch Claude Code with permissions pre-approved."
echo "When prompted, type the following command:"
echo ""
echo "  /plugin ruvnet/claude-flow"
echo ""
echo "Press Enter to continue..."
read
claude-code --dangerously-skip-permissions
EOF
chmod +x "$WORKSPACE_DIR/install-claude-flow.sh"

# Azure login helper
cat > "$WORKSPACE_DIR/azure-login.sh" << 'EOF'
#!/bin/bash
if [ -n "$AZURE_CLIENT_ID" ] && [ -n "$AZURE_CLIENT_SECRET" ] && [ -n "$AZURE_TENANT_ID" ]; then
    echo "Logging in to Azure with service principal..."
    az login --service-principal \
        --username "$AZURE_CLIENT_ID" \
        --password "$AZURE_CLIENT_SECRET" \
        --tenant "$AZURE_TENANT_ID"
    
    if [ -n "$AZURE_SUBSCRIPTION_ID" ]; then
        echo "Setting Azure subscription..."
        az account set --subscription "$AZURE_SUBSCRIPTION_ID"
    fi
    
    echo "Azure login complete!"
    az account show
else
    echo "Error: Azure credentials not found in environment variables"
    echo "Please set AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, and AZURE_TENANT_ID"
    exit 1
fi
EOF
chmod +x "$WORKSPACE_DIR/azure-login.sh"

# Create a verification script
cat > "$WORKSPACE_DIR/verify-setup.sh" << 'EOF'
#!/bin/bash
echo "=========================================="
echo "Verifying Codespace Setup"
echo "=========================================="

echo ""
echo "Node.js:"
node --version

echo ""
echo "npm:"
npm --version

echo ""
echo "Python:"
python3 --version

echo ""
echo "pip:"
pip --version

echo ""
echo "Git:"
git --version

echo ""
echo "Azure CLI:"
az version --output table

echo ""
echo "AWS CLI:"
aws --version

echo ""
echo "Claude Code:"
if command -v claude-code &> /dev/null; then
    echo "✓ Claude Code installed"
    claude-code --version 2>/dev/null || echo "  (version command not available)"
    echo "✓ Alias configured: 'claude' = 'claude-code --dangerously-skip-permissions'"
else
    echo "✗ Claude Code not found"
fi

echo ""
echo "Claude-Flow Plugin:"
echo "To install or verify Claude-Flow, run:"
echo "  claude    (or: claude-code --dangerously-skip-permissions)"
echo "Then type: /plugin ruvnet/claude-flow"

echo ""
echo "Anthropic Python SDK:"
if python3 -c "import anthropic" 2>/dev/null; then
    echo "✓ Anthropic Python SDK installed"
    python3 -c "import anthropic; print(f'Version: {anthropic.__version__}')"
else
    echo "✗ Anthropic Python SDK not found"
fi

echo ""
echo "Environment Variables:"
echo "ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:+[SET]}"
echo "AZURE_SUBSCRIPTION_ID: ${AZURE_SUBSCRIPTION_ID:+[SET]}"
echo "AZURE_TENANT_ID: ${AZURE_TENANT_ID:+[SET]}"
echo "AZURE_CLIENT_ID: ${AZURE_CLIENT_ID:+[SET]}"
echo "AZURE_CLIENT_SECRET: ${AZURE_CLIENT_SECRET:+[SET]}"
echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:+[SET]}"
echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:+[SET]}"
echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION:-[NOT SET]}"

echo ""
echo "=========================================="
echo "Setup verification complete!"
echo "=========================================="
EOF
chmod +x "$WORKSPACE_DIR/verify-setup.sh"

echo ""
echo "=========================================="
echo "Tool Installation Complete!"
echo "=========================================="
echo ""
echo "IMPORTANT: Reload your shell to update PATH:"
echo "  source ~/.bashrc"
echo ""
echo "Note: Secret-dependent configuration (AWS credentials, etc.)"
echo "      will be set up when the container starts and secrets are available."
echo ""
echo "After secrets are configured, run:"
echo "  ./verify-setup.sh           - to verify all installations"
echo "  ./install-claude-flow.sh    - to install Claude-Flow plugin"
echo "  ./azure-login.sh            - to authenticate with Azure"
echo "  claude                      - to start Claude Code"
echo "=========================================="
