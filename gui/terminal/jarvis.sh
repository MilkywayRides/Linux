#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

# ASCII Art Banner
cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ██████╗ ██╗      █████╗ ███████╗███████╗███╗   ██╗███████╗   ║
║   ██╔══██╗██║     ██╔══██╗╚══███╔╝██╔════╝████╗  ██║██╔════╝   ║
║   ██████╔╝██║     ███████║  ███╔╝ █████╗  ██╔██╗ ██║█████╗     ║
║   ██╔══██╗██║     ██╔══██║ ███╔╝  ██╔══╝  ██║╚██╗██║██╔══╝     ║
║   ██████╔╝███████╗██║  ██║███████╗███████╗██║ ╚████║███████╗   ║
║   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝   ║
║                                                                  ║
║              N E U R O   O P E R A T I N G   S Y S T E M        ║
╚══════════════════════════════════════════════════════════════════╝
EOF

echo -e "${CYAN}"
echo "Initializing BlazeNeuro Interface..."
sleep 0.5

# Boot sequence animation
echo -e "${GREEN}[✓] Quantum Core Online${NC}"
sleep 0.2
echo -e "${GREEN}[✓] Neural Network Initialized${NC}"
sleep 0.2
echo -e "${GREEN}[✓] Holographic Display Active${NC}"
sleep 0.2
echo -e "${GREEN}[✓] Security Protocols Engaged${NC}"
sleep 0.3

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}System Status: ${GREEN}OPERATIONAL${NC}"
echo -e "${CYAN}User: ${MAGENTA}$(whoami)${NC}"
echo -e "${CYAN}Hostname: ${MAGENTA}$(hostname)${NC}"
echo -e "${CYAN}Kernel: ${MAGENTA}$(uname -r)${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""

# Main menu
while true; do
    echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}COMMAND CENTER${NC}                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[1]${NC} System Monitor                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[2]${NC} Network Scanner                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[3]${NC} File Explorer                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[4]${NC} Terminal Access                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}[5]${NC} Launch Web GUI                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${RED}[0]${NC} Shutdown                                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "${YELLOW}blazeneuro>${NC} "
    read choice

    case $choice in
        1)
            clear
            echo -e "${CYAN}═══ SYSTEM MONITOR ═══${NC}"
            top -n 1 | head -20
            echo ""
            read -p "Press Enter to continue..."
            clear
            ;;
        2)
            clear
            echo -e "${CYAN}═══ NETWORK SCANNER ═══${NC}"
            ip addr show
            echo ""
            read -p "Press Enter to continue..."
            clear
            ;;
        3)
            clear
            echo -e "${CYAN}═══ FILE EXPLORER ═══${NC}"
            ls -lah --color=auto
            echo ""
            read -p "Press Enter to continue..."
            clear
            ;;
        4)
            clear
            echo -e "${GREEN}Entering terminal mode...${NC}"
            /bin/bash
            clear
            ;;
        5)
            echo -e "${GREEN}Launching Web GUI...${NC}"
            /opt/blazeneuro/gui/web/start.sh &
            ;;
        0)
            echo -e "${RED}Shutting down BlazeNeuro...${NC}"
            sleep 1
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid command${NC}"
            sleep 1
            clear
            ;;
    esac
done
