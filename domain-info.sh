#!/bin/bash

# Set your ipinfo.io API key here (get one at https://ipinfo.io/signup)
API_KEY="YOUR_API_KEY_HERE"

OUTPUT_DIR="./Website_Analysis"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

error_exit() {
    echo -e "${RED}❌ $1${NC}" >&2
    [[ -n "$2" ]] && echo -e "${RED}Details in $2${NC}" >&2
    exit 1
}

usage() {
    echo "Usage: $0 [-o output_file] [-h]"
    echo "  -o  Specify output file (default: <domain>_YYYYMMDD_HHMMSS.txt)"
    echo "  -h  Show this help message"
    exit 0
}

check_commands() {
    local commands=("whois:whois" "dig:dnsutils" "curl:curl" "jq:jq")
    for cmd in "${commands[@]}"; do
        IFS=':' read -r command pkg <<< "$cmd"
        command -v "$command" &>/dev/null || error_exit "'$command' not installed. Install with: sudo apt install $pkg"
    done
}

clean_domain() {
    local domain=$1
    domain=$(echo "$domain" | tr '[:upper:]' '[:lower:]' | sed -E 's#^https?://##; s#/.*$##; s/^www\.//')
    [[ "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] || error_exit "Invalid domain format: $domain"
    echo "$domain"
}

get_whois_data() {
    local domain=$1
    local whois_data
    whois_data=$(whois "$domain" 2>>"$ERROR_LOG") || error_exit "Failed to retrieve WHOIS data" "$ERROR_LOG"
    [[ -z "$whois_data" ]] && error_exit "No WHOIS data returned" "$ERROR_LOG"
    echo "$whois_data"
}

parse_whois() {
    local whois_data=$1
    local registrar abuse created
    registrar=$(echo "$whois_data" | grep -iE 'Registrar:|Sponsoring Registrar:' | head -n1 | cut -d: -f2- | xargs)
    abuse=$(echo "$whois_data" | grep -i 'abuse' | grep -i 'email' | head -n1 | cut -d: -f2- | xargs)
    created=$(echo "$whois_data" | grep -iE 'Creation Date:|Created On:' | head -n1 | cut -d: -f2- | xargs)
    echo "${registrar:-Not found}|${abuse:-Not found}|${created:-Not found}"
}

get_ip_info() {
    local domain=$1
    local ip ipinfo org asn host abuse
    ip=$(dig +short "$domain" A | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
    [[ -z "$ip" ]] && error_exit "No IP address found for $domain"
    ipinfo=$(curl -s --fail "https://ipinfo.io/$ip/json?token=${API_KEY:-$IPINFO_API_KEY}" 2>>"$ERROR_LOG") || error_exit "Failed to retrieve IP info. Check API key or $ERROR_LOG" "$ERROR_LOG"
    [[ -z "$ipinfo" ]] && error_exit "No IP info returned" "$ERROR_LOG"
    org=$(echo "$ipinfo" | jq -r '.org // "Not found"')
    asn=$(echo "$org" | awk '{print $1}')
    host=$(echo "$org" | cut -d' ' -f2-)
    abuse=$(echo "$ipinfo" | jq -r '.abuse.email // "Not found"')
    echo "$ip|$org|$asn|$host|$abuse"
}

while getopts "o:h" opt; do
    case $opt in
        o) OUTPUT_FILE="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[[ "$API_KEY" == "YOUR_API_KEY_HERE" && -z "$IPINFO_API_KEY" ]] && error_exit "Please set your ipinfo.io API key at the top of the script or as IPINFO_API_KEY environment variable"

read -p "Enter the domain to search (e.g., example.com): " RAW_DOMAIN
[[ -z "$RAW_DOMAIN" ]] && error_exit "No domain provided"

CLEAN_DOMAIN=$(clean_domain "$RAW_DOMAIN")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_FILE:-${CLEAN_DOMAIN}_$TIMESTAMP.txt}"
ERROR_LOG="${CLEAN_DOMAIN}_error.log"

check_commands

echo -e "${GREEN}📦 Gathering info for: $RAW_DOMAIN${NC}"
echo "---------------------------"

WHOIS_DATA=$(get_whois_data "$CLEAN_DOMAIN")
IFS='|' read -r REGISTRAR REGISTRAR_ABUSE CREATED <<< "$(parse_whois "$WHOIS_DATA")"
IFS='|' read -r IP FULL_ORG ASN HOST_PROVIDER HOST_ABUSE <<< "$(get_ip_info "$CLEAN_DOMAIN")"

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

mkdir -p "$OUTPUT_DIR"
cp "$OUTPUT_FILE" "$OUTPUT_DIR/completed_${CLEAN_DOMAIN}_$TIMESTAMP.txt"

echo -e "${GREEN}✅ Results saved to $OUTPUT_FILE${NC}"
