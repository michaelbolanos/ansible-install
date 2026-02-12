#!/bin/bash
#==============================================================================
# Script Name: ansible-work-menu.sh
# Description: This script is for running Ansible tasks and checking system
# Author: Michael Bolanos
# Company: offthegridit
# Website: https://github.com/michaelbolanos
# Version: 1.1
# License: MIT
#==============================================================================
# Usage: $>ansible-work-menu.sh
#==============================================================================

# Exit on errors, undefined variables, and pipe failures
set -euo pipefail

# Define script directories
USER_SCRIPT_DIR="$HOME/otg"
GLOBAL_SCRIPT_DIR="/otg"
ANSIBLE_HOSTS_FILE="/etc/ansible/hosts"

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Ensure required packages are installed
MISSING_PKGS=""
for cmd in whiptail asciiquarium cmatrix neofetch nano ansible-playbook sudo grep wg curl; do
    if ! command_exists "$cmd"; then
        MISSING_PKGS+="$cmd "
    fi
done

if [ -n "$MISSING_PKGS" ]; then
    echo -e "\e[31mMissing required packages: $MISSING_PKGS\e[0m"
    echo "Please install them first (e.g., sudo apt install $MISSING_PKGS)."
    exit 1
fi

# Set whiptail background color to green
export NEWT_COLORS='
    root=green,black
    window=green,black
    border=green,black
    textbox=green,black
    button=black,green
    entry=black,green
'

# Main interactive menu
while true; do
    CHOICE=$(whiptail --title "Welcome to offthegridit" --menu "Select an option:" 20 70 14 \
        "1" "Exit to terminal" \
        "2" "Show system info" \
        "3" "Check WAN & Network" \
        "4" "Open text editor" \
        "5" "Reboot system" \
        "6" "Run Ansible Playbook (Normal)" \
        "7" "Run Ansible Playbook (Prompt SSH Password)" \
        "8" "View Ansible Hosts" \
        "9" "Edit Ansible Inventory Files" \
        "10" "Check for passwords in .ini files" \
        "11" "Check & Connect to WireGuard" \
        "12" "Disconnect from WireGuard" \
        "13" "Show active WireGuard connections" \
        "14" "Run Matrix Screensaver" \
        "15" "Open Bash shell" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) break ;;  # Exit to terminal
        
        2)  
            clear
            echo "===== System Information ====="
            neofetch --stdout | tee /dev/tty | less
            read -p "Press Enter to continue..."
            ;;
        
        3)  
            WAN_IP=$(curl -s ifconfig.me || echo "Unknown")
            NETWORK_STATUS=$(ping -c 5 8.8.8.8 2>&1 || echo "Network unreachable")
            whiptail --title "Network & WAN Status" --msgbox "WAN IP: $WAN_IP\n\nNetwork Test:\n$NETWORK_STATUS" 15 80
            ;;
        
        4) nano ;;
        
        5) 
            if whiptail --title "Confirm Reboot" --yesno "Are you sure you want to reboot the system?" 10 60; then
                sudo reboot
            fi
            ;;
        
        6|7)  
            PLAYBOOKS=()
            while IFS= read -r file; do
                PLAYBOOKS+=("$file")
            done < <(find "$USER_SCRIPT_DIR" "$GLOBAL_SCRIPT_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null || true)

            if [ ${#PLAYBOOKS[@]} -eq 0 ]; then
                whiptail --title "Run Ansible Playbook" --msgbox "No playbooks found." 10 60
                continue
            fi

            MENU_OPTIONS=()
            for i in "${!PLAYBOOKS[@]}"; do
                MENU_OPTIONS+=("$i" "$(basename "${PLAYBOOKS[$i]}")")
            done
            PLAYBOOK_CHOICE=$(whiptail --title "Run Ansible Playbook" --menu "Select a playbook to run:" 20 60 10 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)

            if [[ -n "$PLAYBOOK_CHOICE" ]]; then
                SELECTED_PLAYBOOK="${PLAYBOOKS[$PLAYBOOK_CHOICE]}"
                clear
                echo "Running playbook: $SELECTED_PLAYBOOK"
                echo "================================"
                
                if [ "$CHOICE" == "6" ]; then
                    if ansible-playbook "$SELECTED_PLAYBOOK"; then
                        whiptail --title "Playbook Execution" --msgbox "Playbook $SELECTED_PLAYBOOK completed successfully." 10 60
                    else
                        whiptail --title "Playbook Execution" --msgbox "ERROR: Playbook $SELECTED_PLAYBOOK failed. Check the output above." 10 60
                        read -p "Press Enter to continue..."
                    fi
                else
                    if ansible-playbook -k "$SELECTED_PLAYBOOK"; then
                        whiptail --title "Playbook Execution" --msgbox "Playbook $SELECTED_PLAYBOOK completed successfully." 10 60
                    else
                        whiptail --title "Playbook Execution" --msgbox "ERROR: Playbook $SELECTED_PLAYBOOK failed. Check the output above." 10 60
                        read -p "Press Enter to continue..."
                    fi
                fi
            fi
            ;;
        
        8)  
            if [ -f "$ANSIBLE_HOSTS_FILE" ]; then
                whiptail --title "Ansible Hosts File" --textbox "$ANSIBLE_HOSTS_FILE" 20 80
            else
                whiptail --title "Ansible Hosts" --msgbox "Hosts file not found at $ANSIBLE_HOSTS_FILE" 10 60
            fi
            ;;
        
        9)  
            INVENTORY_FILES=()
            while IFS= read -r file; do
                INVENTORY_FILES+=("$file")
            done < <(find "$USER_SCRIPT_DIR" "$GLOBAL_SCRIPT_DIR" -type f \( -name "inventory*" -o -name "hosts*" -o -name "*.ini" \) 2>/dev/null || true)

            if [ ${#INVENTORY_FILES[@]} -eq 0 ]; then
                whiptail --title "Edit Ansible Inventory" --msgbox "No inventory files found." 10 60
                continue
            fi

            MENU_OPTIONS=()
            for i in "${!INVENTORY_FILES[@]}"; do
                MENU_OPTIONS+=("$i" "${INVENTORY_FILES[$i]}")
            done
            INVENTORY_CHOICE=$(whiptail --title "Edit Ansible Inventory" --menu "Select an inventory file to edit:" 20 60 10 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)

            if [[ -n "$INVENTORY_CHOICE" ]]; then
                sudo nano "${INVENTORY_FILES[$INVENTORY_CHOICE]}"
            fi
            ;;
        
        10)  
            PASSWORD_FINDINGS=$(grep -rn "password\s*=" "$USER_SCRIPT_DIR" "$GLOBAL_SCRIPT_DIR" --include="*.ini" 2>/dev/null || true)
            if [ -n "$PASSWORD_FINDINGS" ]; then
                whiptail --title "Password Security Check" --msgbox "WARNING: Found potential passwords in .ini files:\n\n$PASSWORD_FINDINGS\n\nConsider using Ansible Vault for sensitive data." 20 80
            else
                whiptail --title "Password Security Check" --msgbox "No plaintext passwords found in .ini files." 10 60
            fi
            ;;
        
        11)  
            WG_STATUS=$(sudo wg show 2>/dev/null || true)
            if [ -n "$WG_STATUS" ]; then
                whiptail --title "WireGuard Status" --msgbox "WireGuard is already connected:\n\n$WG_STATUS" 15 80
            else
                WG_CONFIGS=($(ls /etc/wireguard/*.conf 2>/dev/null || true))
                if [ ${#WG_CONFIGS[@]} -eq 0 ]; then
                    whiptail --title "WireGuard" --msgbox "No WireGuard configurations found in /etc/wireguard/" 10 60
                    continue
                fi

                MENU_OPTIONS=()
                for i in "${!WG_CONFIGS[@]}"; do
                    MENU_OPTIONS+=("$i" "$(basename "${WG_CONFIGS[$i]}")")
                done
                WG_CHOICE=$(whiptail --title "Connect to WireGuard" --menu "Select a WireGuard configuration to connect:" 20 60 10 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)

                if [[ -n "$WG_CHOICE" ]]; then
                    WG_INTERFACE=$(basename "${WG_CONFIGS[$WG_CHOICE]}" .conf)
                    if sudo wg-quick up "$WG_INTERFACE"; then
                        whiptail --title "WireGuard" --msgbox "WireGuard connected successfully to $WG_INTERFACE" 10 60
                    else
                        whiptail --title "WireGuard" --msgbox "ERROR: Failed to connect to $WG_INTERFACE" 10 60
                    fi
                fi
            fi
            ;;
        
        12)  
            ACTIVE_WG=$(sudo wg show interfaces 2>/dev/null || true)
            if [ -z "$ACTIVE_WG" ]; then
                whiptail --title "WireGuard Disconnect" --msgbox "No active WireGuard connections found." 10 60
            else
                # If multiple interfaces, let user choose
                IFS=' ' read -r -a WG_INTERFACES <<< "$ACTIVE_WG"
                if [ ${#WG_INTERFACES[@]} -eq 1 ]; then
                    if sudo wg-quick down "${WG_INTERFACES[0]}"; then
                        whiptail --title "WireGuard Disconnect" --msgbox "Disconnected from ${WG_INTERFACES[0]}" 10 60
                    else
                        whiptail --title "WireGuard Disconnect" --msgbox "ERROR: Failed to disconnect from ${WG_INTERFACES[0]}" 10 60
                    fi
                else
                    MENU_OPTIONS=()
                    for i in "${!WG_INTERFACES[@]}"; do
                        MENU_OPTIONS+=("$i" "${WG_INTERFACES[$i]}")
                    done
                    WG_DISCONNECT_CHOICE=$(whiptail --title "Disconnect WireGuard" --menu "Select interface to disconnect:" 20 60 10 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)
                    
                    if [[ -n "$WG_DISCONNECT_CHOICE" ]]; then
                        if sudo wg-quick down "${WG_INTERFACES[$WG_DISCONNECT_CHOICE]}"; then
                            whiptail --title "WireGuard Disconnect" --msgbox "Disconnected from ${WG_INTERFACES[$WG_DISCONNECT_CHOICE]}" 10 60
                        else
                            whiptail --title "WireGuard Disconnect" --msgbox "ERROR: Failed to disconnect" 10 60
                        fi
                    fi
                fi
            fi
            ;;
        
        13) 
            WG_STATUS=$(sudo wg show 2>/dev/null || true)
            if [ -z "$WG_STATUS" ]; then
                whiptail --title "Active WireGuard Connections" --msgbox "No active WireGuard connections." 15 80
            else
                whiptail --title "Active WireGuard Connections" --msgbox "$WG_STATUS" 15 80
            fi
            ;;
        
        14)  
            if whiptail --title "Matrix Screensaver" --yesno "Start Matrix screensaver?\n\nPress CTRL+C to exit when running." 10 60; then
                clear
                cmatrix -C green -abs || true
            fi
            ;;
        
        15) bash ;;  # Open Bash shell
        
        *) 
            if [ -n "$CHOICE" ]; then
                whiptail --title "Invalid Option" --msgbox "Invalid selection. Please try again." 8 50
            fi
            ;;
    esac
done
