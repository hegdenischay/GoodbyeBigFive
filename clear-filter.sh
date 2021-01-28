#!/bin/bash
if [[ $1 == "--help" ]]; then
	#echo "This script will clear your PF filter"
    echo "This script will clear the ipset that was created."
    exit 1
fi
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#pfctl -d
#pfctl -F all
#pfctl -e
iptables -D INPUT -m set --match-set techgiant-amazon src -j DROP
iptables -D INPUT -m set --match-set techgiant-google src -j DROP
iptables -D INPUT -m set --match-set techgiant-facebook src -j DROP
iptables -D INPUT -m set --match-set techgiant-apple src -j DROP
iptables -D INPUT -m set --match-set techgiant-microsoft src -j DROP
ipset destroy techgiant-amazon -exist
ipset destroy techgiant-google -exist
ipset destroy techgiant-facebook -exist
ipset destroy techgiant-microsoft -exist
ipset destroy techgiant-apple -exist
