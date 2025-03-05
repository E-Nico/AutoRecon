#!/bin/zsh

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
MAGENTA='\e[35m'
NC='\e[0m'  # Réinitialisation

echo 'AutoRecon - v0'
echo 'Welcome on the AutRecon script which help you with your reco scans. Before executing this script, take care to have take note of this prerequisites :'
echo '-Target is  a linux machine'
echo '-You have the right to do it on you target '
var=$1

if [ -z "$var" ]; then
	echo -e "${RED}Entrer une IP${NC}"
else
	echo -e "${GREEN}[+] TARGET = $var${NC}"
	export TARGET=$var
fi



if ping -c 3 "$TARGET" | grep -q "Destination Host Unreachable"; then
	echo "${RED}L'hôte est deco, vérifie que la machine est lancée et que tu as bien lancé ton VPN ${NC}"
else
	echo "${GREEN}MACHINE UP${NC}"
fi

echo -e "${YELLOW}[/\] START SCANNING${NC}"

echo -e "${MAGENTA}[*] SCAN NMAP ${NC}"
result_nmap=$(nmap -sCV $TARGET)
echo -e "$result_nmap"

#if port 80
echo -e "${MAGENTA}[*] SUBDOMAINS SCANS${NC}"
#resul_gobuster=gobuster dir -u http://$TARGET/ -w /usr/share/dirb/wordlists/common.txt -x php,txt,html -b 301 --exclude-length 6609 -k
echo -e "${YELLOW}[-] LANCEMENT DIRB${NC}"
dirb http://$TARGET/
echo -e "${YELLOW}[-] LANCEMENT FEROXBUSTER${NC}"
feroxbuster -u http://$TARGET -C 503
echo -e "${MAGENTA}[*] VHOST SCANS${NC}"
echo -e "${YELLOW}[-] LANCEMENT FFUF${NC}"
ffuf -c -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -u http://$TARGET  -H "Host: FUZZ.$TARGETi" --fc 301,302
echo -e "${MAGENTA}[*] WEB SCANNING${NC}"
echo -e "${YELLOW}[-] LANCEMENT NIKTO${NC}"
nikto -host $TARGET
echo -e "${YELLOW}[-] LANCEMENT WHATWEB (CMS)${NC}"
whatweb $TARGET
echo -e "${YELLOW}[-] LANCEMENT WAPITI ${NC}"
wapiti -u http://$TARGET
echo -e "${MAGENTA}[*] DEEP ANALYSE${NC}"
nmap -sU $TARGET
echo -e " ~ FIN DE LA PHASE DE RECONNAISSANCE ! ~"
