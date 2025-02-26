#!/bin/bash

# Set terminal colors
GREEN_BG="\e[42m"
GREY_BG="\e[100m"
RESET="\e[0m"

# Function to display the menu
show_menu() {
    clear
    echo -e "${GREEN_BG}=============== Secure Admin Menu ===============${RESET}"
    echo -e "${GREY_BG}1. Secure Exit (Unset History & Exit)${RESET}"
    echo -e "${GREY_BG}2. Kill Shell Session (kill -9 $$)${RESET}"
    echo -e "${GREY_BG}3. Check WireGuard Status${RESET}"
    echo -e "${GREY_BG}4. Restart Network Interfaces${RESET}"
    echo -e "${GREY_BG}5. Show System Info${RESET}"
    echo -e "${GREY_BG}6. Exit${RESET}"
    echo -e "${GREEN_BG}================================================${RESET}"
}

# Function to handle user selection
handle_choice() {
    read -p "Enter your choice: " choice
    case $choice in
        1)  echo "Clearing history and exiting..."
            unset HISTFILE
            history -c
            exit
            ;;
        2)  echo "Killing shell session..."
            kill -9 $$
            ;;
        3)  echo "Checking WireGuard status..."
            wg show
            read -p "Press Enter to continue..."
            ;;
        4)  echo "Restarting network interfaces..."
            sudo systemctl restart networking
            echo "Network interfaces restarted."
            read -p "Press Enter to continue..."
            ;;
        5)  echo "Gathering system information..."
            echo "Hostname: $(hostname)"
            echo "Uptime: $(uptime -p)"
            echo "Memory Usage:"
            free -h
            read -p "Press Enter to continue..."
            ;;
        6)  echo "Exiting..."
            exit 0
            ;;
        *)  echo "Invalid option. Please try again."
            sleep 1
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    handle_choice
done
