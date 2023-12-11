#!/bin/bash

# Firewall State Log File
logFile="/home/kali/MiniFirewall/log.txt"

# Function to read the firewall state from the log file
readState() {
    if [ -e "$logFile" ]; then
        state=$(cat "$logFile")
    else
        state="OFF"
    fi
}

# Function to write the firewall state to the log file
writeState() {
    echo "$state" > "$logFile"
}

# Function to display the main menu
showMainMenu() {
    readState

    # Main menu options
    mainMenuResult=$(whiptail --title "FireBall - Main Menu" --menu "Welcome to FireBall firewall!" 15 60 4 \
        "Start_Firewall" "Start/Stop Firewall" \
        "Settings" "Configure Settings" \
        "Statistics" "Network Statistics" \
	"Show Rules" "Shows the Rules" \
	3>&1 1>&2 2>&3)

    case "$mainMenuResult" in
        "Start_Firewall")
            startFirewallPage
            ;;
        "Settings")
            settingsPage
            ;;
	"Statistics")
	    netStatsPage
	    ;;
    	"Show Rules")
	   showRulesPage
	   ;;
	 *)
            exitPage
            ;;
    esac
}

# Function for Firewall Start/Stop Page
startFirewallPage() {
    readState

    onOffStatus=$(whiptail --title "FireBall - Enable/Disable Firewall" --radiolist "Choose to enable or disable the firewall" 15 60 2 \
        "ON" "Enable Firewall" $([ "$state" == "ON" ] && echo ON || echo OFF) \
        "OFF" "Disable Firewall" $([ "$state" == "OFF" ] && echo ON || echo OFF) \
        3>&1 1>&2 2>&3)

    case "$onOffStatus" in
        "ON")
            if [[ "$state" == "ON" ]]; then
                whiptail --title "FireBall - already on!" --msgbox "Firewall is already on!" 10 40
            else
                whiptail --title "FireBall - Enabled" --msgbox "Firewall Enabled" 10 40
                state="ON"
		sudo ufw enable
            fi
            ;;
        "OFF")
            if [[ "$state" == "OFF" ]]; then
                whiptail --title "FireBall - already off!" --msgbox "Firewall is already off!" 10 40
            else
                whiptail --title "FireBall - Disabled" --msgbox "Firewall Disabled" 10 40
                state="OFF"
		sudo ufw disable
            fi
            ;;
        *)
            showMainMenu
            ;;
    esac
    writeState
    showMainMenu
}

settingsPage() {
    choice=$(whiptail --title "FireBall - Settings" --menu "Choose a rule to edit:" 30 120 6 \
        "Custom rule" "Add custom rule" \
        "Delete rule" "Deletes a rule" \
        "Insert rule" "Inserts a rule at a certain position" \
        "Drop Strange Packets" "Drops packets that originate from the external interface that claim to be internal" \
        "Track and Drop SYN Packets" "Tracks SYN packets and drops the ones in excess" \
        "Limit Number of Fragments per Packet" "Limits the no. of fragments a packet can have" \
        3>&1 1>&2 2>&3)
    case "$choice" in
        "Custom rule")
            customRuleInput=$(whiptail --title "FireBall - Settings" --inputbox "Custom Rule:" 10 40 3>&1 1>&2 2>&3)
            if [ -n "$customRuleInput" ]; then
                sudo iptables $customRuleInput
                iptables-save > /etc/iptables/iptables.rules
                whiptail --msgbox "Settings saved." 10 40
            else
                whiptail --msgbox "Empty rule! Settings not saved." 10 40
            fi
            ;;
        "Delete rule")
            deleteRuleInput=$(whiptail --title "FireBall - Settings" --inputbox "Delete Rule:" 10 40 3>&1 1>&2 2>&3)
            if [ -n "$deleteRuleInput" ]; then
                sudo iptables -D INPUT $deleteRuleInput
                iptables-save > /etc/iptables/iptables.rules
                whiptail --msgbox "Settings saved." 10 40
            else
                whiptail --msgbox "Empty rule! Settings not saved." 10 40
            fi
            ;;
        "Insert rule")
            addRuleInput=$(whiptail --title "FireBall - Settings" --inputbox "Add Rule:" 10 40 3>&1 1>&2 2>&3)
            position=$(whiptail --title "FireBall - Settings" --inputbox "Position:" 10 40 3>&1 1>&2 2>&3)
            if [ -n "$addRuleInput" ] && [ -n "$position" ]; then
                sudo iptables -I INPUT $position $addRuleInput
                iptables-save > /etc/iptables/iptables.rules
                whiptail --msgbox "Settings saved." 10 40
            else
                whiptail --msgbox "Empty input! Settings not saved." 10 40
            fi
            ;;
        "Drop Strange Packets")
            port=$(whiptail --title "FireBall - Settings" --inputbox "Enter the outbound interface:" 10 40 3>&1 1>&2 2>&3)
            ipRange=$(whiptail --title "FireBall - Settings" --inputbox "Enter the network address of your network:" 10 40 3>&1 1>&2 2>&3)
            if [ -n "$port" ] && [ -n "$ipRange" ]; then
                sudo iptables -A INPUT -i $port -s $ipRange -j DROP
                iptables-save > /etc/iptables/iptables.rules
                whiptail --msgbox "Settings saved." 10 40
            else
                whiptail --msgbox "Empty input! Settings not saved." 10 40
            fi
            ;;
        "Track and Drop SYN Packets")
            sudo iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST SYN -j DROP
	    iptables-save > /etc/iptables/iptables.rules
            whiptail --msgbox "Settings saved." 10 40
            ;;
        "Limit Number of Fragments per Packet")
            noFragments=$(whiptail --title "FireBall - Settings" --inputbox "Enter the maximum number of fragments a packet can have:" 10 40 3>&1 1>&2 2>&3)
            if [ -n "$noFragments" ]; then
                sudo iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN -m connlimit --connlimit-above $noFragments --connlimit-mask 32 -j REJECT --reject-with tcp-reset
                iptables-save > /etc/iptables/iptables.rules
                whiptail --msgbox "Settings saved." 10 40
            else
                whiptail --msgbox "Empty input! Settings not saved." 10 40
            fi
            ;;
        *)
            echo "Error!"
            ;;
    esac
    showMainMenu
}

# Function for Exit Page
exitPage() {
    if whiptail --title "FireBall - Exit" --yesno "Are you sure you want to exit?" 10 40; then
        exit 0
    else
        showMainMenu
    fi
}

#Function to display network statistics
netStatsPage() {
   netstat -tuwpln > /home/kali/Firewall/netstat.txt
   whiptail --title "FireBall - Statistics" --textbox /home/kali/Firewall/netstat.txt 30 80
   rm /home/kali/Firewall/netstat.txt
   showMainMenu
}

# Function to display iptables rules
showRulesPage() {
   sudo iptables -L > /home/kali/Firewall/iptables.txt
   whiptail --title "FireBall - Rules" --textbox /home/kali/Firewall/iptables.txt 30 80
   rm /home/kali/Firewall/iptables.txt
   showMainMenu
}

# Initial call to the main menu
showMainMenu
