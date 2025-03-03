# 🛠️ Ultimate Security Toolkit

A bash script for setting up a powerful security toolkit on a fresh Linux system. This script automates the installation of essential security tools, configures shell environments, and enhances your penetration testing workflow.

## 📌 Features

- Automated installation of popular security tools (ProjectDiscovery, TomNomNom, etc.)
- Supports **bash** and **zsh** shells
- Optional installation of **Oh My Zsh** and setting **zsh** as the default shell
- Python virtual environment setup with essential libraries
- Downloads and configures popular payload lists and wordlists

## 📂 Tools Installed

- **Recon Tools:** subfinder, assetfinder, waybackurls, gau
- **Scanning Tools:** nmap, naabu, nuclei, httpx
- **Exploitation Tools:** sqlmap, XSStrike, dalfox
- **Wordlists & Payloads:** SecLists, XSS payloads
- **Other Utilities:** wfuzz, hakrawler, paramspider, massdns

## 🚀 Usage

1. Clone the repository:

```bash
 git clone https://github.com/MohammadAliMehri/Scripts.git
 cd Scripts
```

2. Make the script executable:

```bash
chmod +x install-tools-v5.sh
```

3. Run the script:

```bash
./install-tools-v5.sh
```

4. Follow the prompts to complete the installation.

## 📒 Notes

- Ensure you have `sudo` privileges before running the script.
- This script is designed for **Debian-based** systems (e.g., Ubuntu, Kali Linux).
- Reload your shell configuration after installation:
  - For Bash: `source ~/.bashrc`
  - For Zsh: `source ~/.zshrc`

## 📢 Contributing

Feel free to submit **pull requests** for new features, improvements, or bug fixes.


✅ Created by [MohammadAliMehri](https://github.com/MohammadAliMehri)

