# 🕵️ Domain Info Scanner (Kali Linux)

A Bash script for Kali Linux that performs domain reconnaissance by pulling WHOIS records, DNS information, and IP geolocation details using the ipinfo.io API.

---

## 🌐 What It Does

- Normalizes domain input (removes protocols and www)
- Validates domain format
- Retrieves WHOIS data:
  - Registrar
  - Registrar Abuse Contact
  - Domain Creation Date
- Resolves domain A record to IP
- Queries [ipinfo.io](https://ipinfo.io/) to get:
  - Hosting Provider (ORG)
  - ASN
  - Abuse Contact for IP
- Saves results to a timestamped text file
- Copies that file to a standard analysis folder:  
  `/home/kali/Website analysis/`

---

## 🔐 API Key Requirement

This script **requires a free API key from ipinfo.io** to work properly.

### Steps to Get Your Key:
1. Go to [https://ipinfo.io/signup](https://ipinfo.io/signup)
2. Create a free account
3. Once logged in, copy your **Access Token**

### How to Set Your API Key:
1. Open the script:

    ```bash
    nano domain-info.sh
    ```

2. Find the line:

    ```bash
    API_KEY="PASTE_YOUR_API_KEY_HERE"
    ```

3. Replace it with:

    ```bash
    API_KEY="your_actual_key_here"
    ```

4. Save and exit:
    - In nano: `CTRL + O`, `Enter`, `CTRL + X`

---

## 📦 Requirements

This script is built for **Kali Linux** and uses tools commonly preinstalled. If missing, install them with:

```bash
sudo apt update
sudo apt install whois dnsutils curl jq

## ⚙️ Installation
Clone this repository:

bash
Copy
Edit
git clone https://github.com/YOUR_USERNAME/domain-info-scanner.git
cd domain-info-scanner
chmod +x domain-info.sh
🚀 Usage
Run the script:

bash
Copy
Edit
./domain-info.sh
You'll be prompted:

pgsql
Copy
Edit
Enter the domain to search (e.g., example.com):
The script will:

Run WHOIS and DNS checks

Query ipinfo.io using your key

Save results to <domain>_YYYYMMDD_HHMMSS.txt

Copy the file to: /home/kali/Website analysis/

Optional: Save with a custom filename
bash
Copy
Edit
./domain-info.sh -o myresults.txt
📁 Output Example
yaml
Copy
Edit
📄 Info for example.com
Generated: 2025-06-10 13:00:00 PDT
========================
Registrar: NameCheap, Inc.
Abuse Contact for Registrar: abuse@namecheap.com
Domain Created: 2020-01-15
IP Address: 93.184.216.34
Hosting Provider: EDGECAST
ASN: AS15133
Abuse Contact for Host: abuse@verizon.com
Saved as:

Copy
Edit
example_com_20250610_130000.txt
Copied to:

bash
Copy
Edit
/home/kali/Website analysis/completed_example_com_20250610_130000.txt
🧯 Troubleshooting
Script exits immediately saying API key is missing?
You must paste your ipinfo.io API key directly into the script.

No IP address found?
The domain may not have an A record. Try a different one.

Missing commands?
Run:
sudo apt install whois dnsutils curl jq

Getting errors from ipinfo?

Check if your API key is correct

Your IP may have hit a rate limit (wait or upgrade your plan)

📂 File Structure
pgsql
Copy
Edit
domain-info-scanner/
├── domain-info.sh        # Main script
└── README.md             # You're reading it
📄 License
This project is licensed under the MIT License.

You are free to use, modify, and share this script with attribution.

🙋 Support
If you encounter bugs or have ideas to improve the script, feel free to open an issue.
