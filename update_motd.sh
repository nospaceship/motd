#!/bin/bash

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Unsupported distribution. Exiting."
    exit 1
fi

# Install figlet if not present
if ! command -v figlet &> /dev/null; then
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update && sudo apt-get install -y figlet
            ;;
        fedora)
            sudo dnf install -y figlet
            ;;
        arch)
            sudo pacman -Sy figlet
            ;;
        *)
            echo "Unsupported distribution for automatic figlet installation."
            exit 1
            ;;
    esac
fi

# Create MOTD message
MOTD_FILE="/etc/motd"

# Gather system information
CPU_TEMP=""
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    CPU_TEMP=$(echo "scale=1; $(cat /sys/class/thermal/thermal_zone0/temp) / 1000" | bc)
else
    CPU_TEMP="N/A"
fi

MEMORY_USAGE=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
DISK_USAGE=$(df -h / | awk '/\// {print $3 "/" $2}')
PING_RESULT=$(ping -c 1 8.8.8.8 &> /dev/null && echo "Online" || echo "Offline")

# Generate the MOTD content
{
    echo "###############################################"
    figlet "JORDAN'S LAB"
    echo "###############################################"
    echo ""
    echo "CPU Temperature: $CPU_TEMP°C"
    echo "Memory Usage: $MEMORY_USAGE"
    echo "Disk Usage: $DISK_USAGE"
    echo "Internet Status: $PING_RESULT"
    echo ""
} | sudo tee $MOTD_FILE > /dev/null

# Apply correct permissions
sudo chmod 644 $MOTD_FILE

# Notify user
echo "MOTD successfully updated with 'JORDAN'S LAB' message and system information."
