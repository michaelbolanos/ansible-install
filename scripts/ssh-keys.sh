#!/bin/bash
#==============================================================================
# Script Name: ssh-keys.sh
# Description: This script will copy your public key to hosts listed in hosts.txt
# Author: Michael Bolanos
# Company: offthegridit
# Website: https://github.com/michaelbolanos
# Version: 1.2 (Now prompts for password)
# License: MIT
#==============================================================================
# Usage: Run this script, and it will ask for your password.
#==============================================================================

USER="itsupport"  # Change this to the correct username
SSH_KEY="${HOME}/.ssh/id_rsa.pub"  # Change if using id_ed25519.pub

# Prompt user for SSH password
read -s -p "Enter SSH password: " PASSWORD
echo  # Print a new line after password entry

# Ensure sshpass is installed
if ! command -v sshpass &>/dev/null; then
    echo "Error: sshpass is not installed. Install it using: sudo apt install sshpass"
    exit 1
fi

# Ensure SSH key exists
if [[ ! -f "$SSH_KEY" ]]; then
    echo "Error: No SSH key found at $SSH_KEY. Generate one using: ssh-keygen -t ed25519"
    exit 1
fi

# Ensure hosts.txt exists
if [[ ! -f "hosts.txt" ]]; then
    echo "Error: hosts.txt file not found!"
    exit 1
fi

# Start SSH agent if not already running
eval "$(ssh-agent -s)" &>/dev/null
ssh-add "$SSH_KEY" &>/dev/null

# Loop through hosts and copy SSH key
while IFS= read -r HOST; do
    if [[ -z "$HOST" ]]; then
        continue  # Skip empty lines
    fi

    echo "Copying SSH key to $HOST..."
    sshpass -p "$PASSWORD" ssh-copy-id -i "$SSH_KEY" -o StrictHostKeyChecking=no "$USER@$HOST"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to copy SSH key to $HOST"
    else
        echo "Successfully copied SSH key to $HOST"
    fi
done < hosts.txt

echo "SSH key setup completed for all hosts."
