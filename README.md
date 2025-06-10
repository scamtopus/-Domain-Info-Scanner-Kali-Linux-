# 🕵️ Domain Info Scanner - Kali Linux

A Bash script for Kali Linux that collects WHOIS, DNS, and IP metadata for any domain using Linux-native tools and the [ipinfo.io](https://ipinfo.io/) API. It outputs a clean report with hosting provider, registrar, and abuse contact details.

---

## 📦 Features

- Cleans and validates domain input
- Retrieves WHOIS data (registrar, creation date, abuse contact)
- Resolves the A record to an IP
- Uses ipinfo.io to retrieve:
  - Hosting provider
  - ASN
  - Abuse contact for the IP
- Saves results to a timestamped `.txt` file
- Automatically copies the file to `/home/kali/Website analysis/`

---

## 🛠️ Requirements

Tested on Kali Linux. You must have these tools installed:

```bash
sudo apt update
sudo apt install whois dnsutils curl jq
```

---

## 🔐 API Key Setup (Required)

This script uses ipinfo.io to query IP address metadata, such as the hosting provider and abuse contact.

### Step 1: Get a Free API Key

- Go to: https://ipinfo.io/signup  
- Create a free account  
- Copy your Access Token (API Key) from the dashboard  

### Step 2: Paste It Into the Script

Open the script file:

```bash
nano domain-info.sh
```

At the top of the file, find this line:

```bash
API_KEY="PASTE_YOUR_API_KEY_HERE"
```

Replace it with your actual key:

```bash
API_KEY="your_actual_key_here"
```

Save and close (`CTRL + O`, `Enter`, then `CTRL + X`)

> ⚠️ If you forget to add your key, the script will exit and warn you.

---

## 🚀 How to Use

Make the script executable:

```bash
chmod +x domain-info.sh
```

Run it:

```bash
./domain-info.sh
```

When prompted, enter a domain (e.g., `example.com`).

The script will:

- Normalize the domain
- Pull WHOIS and DNS info
- Query ipinfo.io for IP ownership
- Output all data to a `.txt` file
- Copy it to your analysis folder

---

## ⚙️ Optional Flags

- `-o filename.txt` – Save output to a custom file  
- `-h` – Display help menu

**Example:**

```bash
./domain-info.sh -o report.txt
```

---

## 📁 Output Example

```
📄 Info for example.com
Generated: 2025-06-10 13:00:00 PDT
=========================
Registrar: NameCheap, Inc.
Abuse Contact for Registrar: abuse@namecheap.com
Domain Created: 2020-01-15
IP Address: 93.184.216.34
Hosting Provider: EDGECAST
ASN: AS15133
Abuse Contact for Host: abuse@verizon.com
```

**This is saved as:**

```
example_com_20250610_130000.txt
```

**And copied to:**

```
/home/kali/Website analysis/completed_example_com_20250610_130000.txt
```

---

## 🧯 Troubleshooting

| Issue                         | Solution                                                    |
|------------------------------|-------------------------------------------------------------|
| Script says API key is missing | Open the script and paste your key at the top              |
| Missing tools (whois, dig)   | Run: `sudo apt install whois dnsutils curl jq`             |
| Domain doesn’t resolve       | Try another domain — it may lack an A record               |
| ipinfo.io fails              | Your key may be invalid or you've hit the rate limit       |

---

## 📂 File Structure

```
.
├── domain-info.sh       # Main script (edit this to add API key)
└── README.md            # You're reading it
```

---

## 🙋 Author

Created by **scamtopus**  
For ethical cybersecurity, awareness, and investigative education.

---

## 🙋 Support

If you encounter bugs or have ideas to improve the script, feel free to [open an issue](https://github.com/scamtopus/-Domain-Info-Scanner-Kali-Linux-/issues).
