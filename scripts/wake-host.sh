#! /usr/bin/env sh

thiscommand="$(basename "$0")"

set -e

if [ $# -eq 0 ]; then
	echo "Usage: $thiscommand [HOST]"
	echo ""
	echo "Sends a magic packet to wake up the host."
	echo "Based on ARP records, so if the DNS cache is stale, it won't work"
	exit 1
fi

host=$1

ip=$(ping -c 1 "$host" | grep PING | awk '{ print $3 }' | sed 's/[()]//g')

echo "Sending magic WOL packet to:"
echo "Host: $host"
echo "IP: $ip"
sudo arp-scan "$ip" | grep "$ip" | awk '{ print $2 }' | xargs wol
