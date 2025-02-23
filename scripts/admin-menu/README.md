# Ansible Work Menu

## Overview

`ansible-work-menu.sh` is an interactive Bash script designed to streamline system administration tasks and manage Ansible playbooks efficiently. It provides a user-friendly interface using `whiptail`, allowing users to execute various system commands, check network connectivity, interact with Ansible playbooks, manage WireGuard VPN connections, and perform other administrative functions.

## Features

- **System Information Display:** Uses `neofetch` to show system details.
- **Network Diagnostics:** Checks WAN IP and pings a public DNS server to assess connectivity.
- **Ansible Playbook Execution:**
  - Runs playbooks located in the user's script directory or the global `/otg` directory.
  - Supports both normal execution and SSH password-prompted execution.
- **Ansible Inventory Management:**
  - Lists and allows editing of inventory files.
  - Supports `.ini`, `inventory*`, and `hosts*` files.
- **WireGuard VPN Management:**
  - Checks active connections.
  - Connects to available WireGuard configurations.
  - Disconnects from an active WireGuard session.
- **Security Audit:** Searches for stored passwords in `.ini` files.
- **System Control:** Supports rebooting and opening a Bash shell.
- **Interactive Visuals:** Includes `cmatrix` (Matrix-style screensaver) for fun visuals.
- **File Editing:** Opens a text editor (`nano`) for quick file modifications.

## Prerequisites

Before running the script, ensure the following packages are installed:

