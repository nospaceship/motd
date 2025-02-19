#!/bin/bash

# Detect distribution and install necessary packages
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Unsupported distribution. Exiting."
    exit 1
fi

# Function to install packages
install_packages() {
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y figlet bc
            ;;
        fedora)
            sudo dnf install -y figlet bc
            ;;
        arch)
            sudo pacman -Sy figlet bc
            ;;
        *)
            echo "Unsupported distribution for automatic installation."
            exit 1
            ;;
    esac
}

# Check and install figlet and bc if not present
if ! command -v figlet &> /dev/null || ! command -v bc &> /dev/null; then
    install_packages
fi

# Define the MOTD file
MOTD_FILE="/etc/motd"

# Gather system information
IP_ADDRESS=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)
CPU_TEMP=""
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    CPU_TEMP=$(echo "scale=1; $(cat /sys/class/thermal/thermal_zone0/temp) / 1000" | bc)
else
    CPU_TEMP="N/A"
fi
MEMORY_USAGE=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
PING_RESULT=$(ping -c 1 8.8.8.8 &> /dev/null && echo "Online" || echo "Offline")

last_login_info=$(last -n 2 -R | tail -n 1)
last_login_user=$(echo "$last_login_info" | awk '{print $1}')
last_login_ip=$(echo "$last_login_info" | awk '{print $3}')
last_login_time=$(echo "$last_login_info" | awk '{print $4, $5, $6, $7, $8}')
last_login_details="User: $last_login_user, IP: $last_login_ip, Time: $last_login_time"

# Create the new MOTD content
NEW_CONTENT=$(cat << EOF

$(figlet "JORDAN'S LAB")


Welcome to my Homelab! This is private lab, all activity is being monitored 
and logged. Please be mindful of the best security practices.

System Information:
--------------------------------
IP Address       : $IP_ADDRESS
Hostname         : $HOSTNAME
CPU Temperature  : $CPU_TEMP°C
Memory Usage     : $MEMORY_USAGE
Disk Usage       : $DISK_USAGE
Internet Status  : $PING_RESULT
Last Login       : $last_login_details



EOF
)

# Backup the existing MOTD
sudo cp $MOTD_FILE ${MOTD_FILE}.bak

# Remove existing '#' border lines and append new content
echo "$NEW_CONTENT" | sudo tee -a $MOTD_FILE > /dev/null

# Apply correct permissions
sudo chmod 644 $MOTD_FILE

# Notify user
echo "MOTD successfully updated with 'JORDAN'S LAB' banner and system information."
