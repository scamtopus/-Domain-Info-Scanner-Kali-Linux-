#!/bin/bash

# Set your ipinfo.io API key here
API_KEY="PASTE_YOUR_API_KEY_HERE"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [-o output_file] [-h]"
    echo "  -o  Specify output file (default: <domain>_YYYYMMDD_HHMMSS.txt)"
    echo "  -h  Show this help message"
    exit 1
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}❌ '$1' not installed. Install with: sudo apt install $2${NC}"
        exit 1
    fi
}

while getopts "o:h" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

read -p "Enter the domain to search (e.g., example.com): " RAW_DOMAIN

DOMAIN=$(echo "$RAW_DOMAIN" | tr '[:upper:]' '[:lower:]' | sed -E 's#^https?://##; s#/.*$##')
CLEAN_DOMAIN=$(echo "$DOMAIN" | sed 's/^www\.//')

if ! echo "$CLEAN_DOMAIN" | grep -qE '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
    echo -e "${RED}❌ Invalid domain format after cleaning: $CLEAN_DOMAIN${NC}"
    exit 1
fi

check_command whois whois
check_command dig dnsutils
check_command curl curl
check_command jq jq

if [ "$API_KEY" = "PASTE_YOUR_API_KEY_HERE" ] || [ -z "$API_KEY" ]; then
    echo -e "${RED}❌ Please paste your ipinfo.io API key at the top of this script.${NC}"
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_FILE:-${CLEAN_DOMAIN}_$TIMESTAMP.txt}"
ERROR_LOG="${CLEAN_DOMAIN}_error.log"

echo -e "${GREEN}\n📦 Gathering info for: $RAW_DOMAIN${NC}"
echo "---------------------------"

WHOIS_DATA=$(whois "$CLEAN_DOMAIN" 2>>"$ERROR_LOG")
if [ $? -ne 0 ] || [ -z "$WHOIS_DATA" ]; then
    echo -e "${RED}❌ Failed to retrieve WHOIS data. Check $ERROR_LOG${NC}"
    exit 1
fi

REGISTRAR=$(echo "$WHOIS_DATA" | grep -iE 'Registrar:|Sponsoring Registrar:' | head -n1 | cut -d: -f2- | xargs)
REGISTRAR_ABUSE=$(echo "$WHOIS_DATA" | grep -i 'abuse' | grep -i 'email' | head -n1 | cut -d: -f2- | xargs)
CREATED=$(echo "$WHOIS_DATA" | grep -iE 'Creation Date:|Created On:' | head -n1 | cut -d: -f2- | xargs)

REGISTRAR=${REGISTRAR:-"Not found"}
REGISTRAR_ABUSE=${REGISTRAR_ABUSE:-"Not found"}
CREATED=${CREATED:-"Not found"}

IP=$(dig +short "$CLEAN_DOMAIN" A | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
if [ -z "$IP" ]; then
    echo -e "${RED}❌ No IP address found for $CLEAN_DOMAIN.${NC}"
    exit 1
fi

IPINFO=$(curl -s --fail "https://ipinfo.io/$IP/json?token=$API_KEY" 2>>"$ERROR_LOG")
if [ $? -ne 0 ] || [ -z "$IPINFO" ]; then
    echo -e "${RED}❌ Failed to retrieve IP info. Check $ERROR_LOG or verify your API key.${NC}"
    exit 1
fi

FULL_ORG=$(echo "$IPINFO" | jq -r '.org // "Not found"')
ASN=$(echo "$FULL_ORG" | awk '{print $1}')
HOST_PROVIDER=$(echo "$FULL_ORG" | cut -d' ' -f2-)
HOST_ABUSE=$(echo "$IPINFO" | jq -r '.abuse.email // "Not found"')

{
    echo "📄 Info for $RAW_DOMAIN"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "========================"
    echo "Registrar: $REGISTRAR"
    echo "Abuse Contact for Registrar: $REGISTRAR_ABUSE"
    echo "Domain Created: $CREATED"
    echo "IP Address: $IP"
    echo "Hosting Provider: $HOST_PROVIDER"
    echo "ASN: $ASN"
    echo "Abuse Contact for Host: $HOST_ABUSE"
} | tee "$OUTPUT_FILE"

echo -e "${GREEN}\n✅ Results saved to $OUTPUT_FILE${NC}"

mkdir -p "/home/kali/Website analysis/"
cp "$OUTPUT_FILE" "/home/kali/Website analysis/completed_${CLEAN_DOMAIN}_$TIMESTAMP.txt"
