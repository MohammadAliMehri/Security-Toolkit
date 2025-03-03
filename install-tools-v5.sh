#!/bin/bash

# Function to configure shell environments (bash/zsh)
# Takes shell type as parameter and sets up necessary configurations
setup_shell_config() {
    local shell_type=$1
    local config_file=""
    
    # Determine configuration file based on shell type
    case "$shell_type" in
        "bash")
            config_file="$HOME/.bashrc"
            ;;
        "zsh")
            config_file="$HOME/.zshrc"
            ;;
    esac
    
    # Add Go binary path to shell configuration if not already present
    if [ -f "$config_file" ]; then
        if ! grep -q 'export PATH=$PATH:$(go env GOPATH)/bin' "$config_file"; then
            echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> "$config_file"
            echo "Added Go binaries to $shell_type PATH"
        fi
    fi
}

# Function to handle Oh My Zsh installation
# Installs Oh My Zsh if not already present
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
        echo "Oh My Zsh installed successfully!"
    else
        echo "Oh My Zsh is already installed."
    fi
}

# Main function to detect and configure available shells
# Handles both bash and zsh configurations
setup_shells() {
    # Setup bash if available
    if [ -f "$HOME/.bashrc" ]; then
        echo "Setting up Bash configuration..."
        setup_shell_config "bash"
    fi

    # Setup zsh if available
    if command -v zsh &> /dev/null; then
        echo "Setting up Zsh configuration..."
        setup_shell_config "zsh"
        
        # Prompt user for Oh My Zsh installation
        read -p "Would you like to install Oh My Zsh? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_oh_my_zsh
            # Prompt for setting zsh as default shell
            read -p "Would you like to set Zsh as your default shell? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                chsh -s $(which zsh)
                echo "Default shell changed to Zsh. Changes will take effect after you log out and log back in."
            fi
        fi
    fi
}

# Initial system update and package installation
echo "Updating and installing packages..."
sudo apt update > /dev/null 2>&1
sudo apt install -y python3.12-venv golang git wget curl jq nmap nikto sqlmap zsh dirsearch wfuzz crunch micro make > /dev/null 2>&1

# Python virtual environment setup
echo "Creating and activating Python virtual environment..."
if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed. Please install Python3 and try again."
    exit 1
fi
python3 -m venv venv > /dev/null 2>&1
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install jinja2 beautifulsoup4 defusedxml requests_ntlm setuptools > /dev/null 2>&1

# Create and enter Tools directory for installations
mkdir -p Tools
cd Tools

# Download security testing payloads
if [ ! -f xss-payload-list.txt ]; then
    wget https://github.com/payloadbox/xss-payload-list/blob/master/Intruder/xss-payload-list.txt -O xss-payload-list.txt > /dev/null 2>&1
fi

# Install Go-based security tools
echo "Installing Go tools..."
declare -A go_tools=(
    # Project Discovery tools
    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    ["dnsx"]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    ["nuclei"]="github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    ["naabu"]="github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    ["notify"]="github.com/projectdiscovery/notify/cmd/notify@latest"
    ["proxify"]="github.com/projectdiscovery/proxify/cmd/proxify@latest"
    ["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
    ["shuffledns"]="github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"

    # TomNomNom tools
    ["assetfinder"]="github.com/tomnomnom/assetfinder@latest"
    ["waybackurls"]="github.com/tomnomnom/waybackurls@latest"
    ["gf"]="github.com/tomnomnom/gf@latest"
    ["httprobe"]="github.com/tomnomnom/httprobe@latest"
    
    # Other security tools
    ["dalfox"]="github.com/hahwul/dalfox/v2@latest"
    ["ffuf"]="github.com/ffuf/ffuf@latest"
    ["gau"]="github.com/lc/gau/v2/cmd/gau@latest"
    ["gobuster"]="github.com/OJ/gobuster/v3@latest"
    ["gowitness"]="github.com/sensepost/gowitness@latest"
    ["amass"]="github.com/owasp-amass/amass/v3/...@master"
    ["hakrawler"]="github.com/hakluke/hakrawler@latest"
)

# Install each Go tool if not already present
for tool in "${!go_tools[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "Installing $tool..."
        go install -v ${go_tools[$tool]} > /dev/null 2>&1
    else
        echo "$tool is already installed."
    fi
done

# Install XSStrike for XSS testing
if [ ! -d "XSStrike-3.1.5" ]; then
    echo "Installing XSStrike..."
    wget https://github.com/s0md3v/XSStrike/archive/refs/tags/3.1.5.tar.gz -O XSStrike.tar.gz > /dev/null 2>&1
    tar -xvzf XSStrike.tar.gz > /dev/null 2>&1
    rm XSStrike.tar.gz > /dev/null 2>&1
else
    echo "XSStrike is already installed."
fi

# Install ex-param for parameter discovery
if [ ! -d "ex-param" ]; then
    echo "Cloning ex-param repository..."
    git clone https://github.com/rootDR/ex-param.git > /dev/null 2>&1
    cd ex-param
    echo "Installing Python dependencies for ex-param..."
    pip install -r requirements.txt > /dev/null 2>&1
    cd ..
else
    echo "ex-param is already installed."
fi

# Install ParamSpider for parameter discovery
if [ ! -d "paramspider" ]; then
    echo "Installing ParamSpider..."
    git clone https://github.com/devanshbatham/paramspider > /dev/null 2>&1
    cd paramspider
    pip install . > /dev/null 2>&1
    cd .. > /dev/null 2>&1
else
    echo "ParamSpider is already installed."
fi

# Install massdns for DNS resolution
if [ ! -d "massdns-1.1.0" ]; then
    echo "Installing massdns..."
    wget https://github.com/blechschmidt/massdns/archive/refs/tags/v1.1.0.tar.gz -O massdns.tar.gz > /dev/null 2>&1
    tar -xvzf massdns.tar.gz > /dev/null 2>&1
    cd massdns-1.1.0
    make > /dev/null 2>&1
    sudo cp bin/massdns /usr/local/bin/
    cd ..
    rm massdns.tar.gz > /dev/null 2>&1
else
    echo "massdns is already installed."
fi

# Install Waymore for wayback machine data collection
if ! command -v waymore &> /dev/null; then
    echo "Installing Waymore..."
    pip3 install waymore > /dev/null 2>&1
else
    echo "Waymore is already installed."
fi

# Install SecLists wordlist collection
if [ ! -d ~/SecLists ]; then
    echo "Cloning SecLists..."
    git clone https://github.com/danielmiessler/SecLists.git ~/SecLists > /dev/null 2>&1
else
    echo "SecLists is already installed."
fi

# Install SQLMap for SQL injection testing
if [ ! -d ~/sqlmap ]; then
    echo "Cloning sqlmap..."
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git ~/sqlmap > /dev/null 2>&1
else
    echo "sqlmap is already installed."
fi

# Install GF patterns for pattern matching
if [ ! -d ~/.gf ]; then
    echo "Cloning gf patterns repository..."
    git clone https://github.com/tomnomnom/gf ~/.gf > /dev/null 2>&1
else
    echo "gf patterns repository is already installed."
fi

# Configure shell environments
setup_shells

# Reload shell configurations
echo "Reloading shell configurations..."
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ]; then
    # Only source zshrc if currently in zsh
    if [ -n "$ZSH_VERSION" ]; then
        source "$HOME/.zshrc"
    fi
fi

# Display completion message and next steps
echo "Installation complete!"
echo "Your shell configurations have been updated for both Bash and Zsh (if installed)."
echo "To ensure all changes take effect, you can:"
echo "- For Bash: source ~/.bashrc"
echo "- For Zsh: source ~/.zshrc"
if [[ $REPLY =~ ^[Yy]$ ]] && [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is installed. You can start using it by running: zsh"
fi