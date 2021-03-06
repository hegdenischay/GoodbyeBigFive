#!/bin/bash
INPUT=data/AS.csv
CDNS=data/CDN.csv
OLDIFS=$IFS
IFS=,
programname=$0
LIMIT="none"

build_rules () {
	echo "$company"
	whois -h whois.radb.net -- "-i origin ${as}" | grep ^route | while read -r ip; do
		ip=${ip//[[:blank:]]/}
		ip=${ip#"route"}
		ip=${ip#"6:"}
		ip=${ip#":"}
		ip=${ip//[[:blank:]]/}
		echo "blocking $ip" 
		ipset add techgiant-$company $ip -exist &>block.out 
	done

}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#if ! grep -qs techgiant /etc/pf.conf; then
#	echo "adding rule to pf.conf"
#	echo 'block out log from any to <techgiant>' >> /etc/pf.conf
#fi


if [ $# -eq 0 ]
  then
    echo "No arguments supplied, blocking all of them"
  else
	LIMIT=$1
fi

if [[ $LIMIT == "--help" ]]; then
	
	echo "usage: sudo $programname [--company]"
    echo "  --amazon      blocks traffic to and from amazon servers"
    echo "  --google      blocks traffic to and from google servers"
    echo "  --facebook    blocks traffic to and from facebook servers"
    echo "  --help        display help"
    echo "  --microsoft   blocks traffic to and from microsoft servers"
    echo "  --apple       blocks traffic to and from apple servers"
    echo "  --fascist     blocks all companies including CDNS"
    exit 1
fi

# pfctl -F all



[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

# ipset create techgiant hash:ip timeout 300
# iptables -I INPUT -m set --match-set techgiant src -j DROP

while read company as 
do
	if [[ $LIMIT == "--"$company || $LIMIT == "none" || $LIMIT == "--fascist" ]]; then
	    ipset create techgiant-$company hash:net timeout -exist 0
	    iptables -C INPUT -m set --match-set techgiant-$company src -j DROP || iptables -I INPUT -m set --match-set techgiant-$company src -j DROP
	    build_rules "$as" "$company"
	fi

done < $INPUT

if [[ $LIMIT == "--fascist" ]]; then
	[ ! -f $CDNS ] && { echo "$CDNS file not found"; exit 99; }
	while read company as 
	do	
		build_rules "$as" "$company"
	
	done < $CDNS
fi
