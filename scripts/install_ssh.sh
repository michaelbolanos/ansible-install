#!/bin/bash
#==============================================================================
# Script Name: install_ssh.sh
# Description: This script installs and configures OpenSSH Server on Ubuntu.
# Author: Michael Bolanos
# Company: offthegridit
# Website: https://github.com/michaelbolanos
# Version: 1.0
# License: MIT
#==============================================================================
# Usage: Run this script with sudo privileges.
#==============================================================================


# Update package list
sudo apt update -y

# Install OpenSSH Server
sudo apt install -y openssh-server

# Ensure SSH service is enabled and running
sudo systemctl enable ssh
sudo systemctl start ssh

# Print SSH status
sudo systemctl status ssh --no-pager
