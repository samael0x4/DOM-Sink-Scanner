#!/bin/bash

# ============================
# DOM Sink Scanner v1.2
# Author: Samael_0x4
# GitHub: https://github.com/samael0x4/DOM-Sink-Scanner/
# ============================

# === Banner ===
clear
echo -e "\e[1;32m"
echo "██████╗  ██████╗ ███╗   ███╗     ███████╗ ██████╗ ██╗   ██╗ ██████╗ ███████╗ ██████╗ ██████╗ "
echo "██╔══██╗██╔═══██╗████╗ ████║     ██╔════╝██╔═══██╗██║   ██║██╔═══██╗██╔════╝██╔════╝ ██╔══██╗"
echo "██████╔╝██║   ██║██╔████╔██║     █████╗  ██║   ██║██║   ██║██║   ██║█████╗  ██║  ███╗██████╔╝"
echo "██╔═══╝ ██║   ██║██║╚██╔╝██║     ██╔══╝  ██║   ██║██║   ██║██║   ██║██╔══╝  ██║   ██║██╔═══╝ "
echo "██║     ╚██████╔╝██║ ╚═╝ ██║     ██║     ╚██████╔╝╚██████╔╝╚██████╔╝███████╗╚██████╔╝██║     "
echo "╚═╝      ╚═════╝ ╚═╝     ╚═╝     ╚═╝      ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     "
echo -e "\e[0m"
echo "               ~ Samael_0x4 | Version: 1.2"
echo "               GitHub: https://github.com/samael0x4/DOM-Sink-Scanner/"
echo ""

# === Config ===
TARGETS="$1"
SINKS="document.write,innerHTML,outerHTML,eval,setTimeout,setInterval,location,src,href,onerror,onload,onmouseover,onfocus,onanimationstart"

# === Output ===
OUTPUT="dom_candidates.txt"
> "$OUTPUT"

# === Scan ===
echo "[*] Scanning targets from: $TARGETS"
cat "$TARGETS" | while read target; do
  echo "[*] Checking: $target"
  if [[ "$target" =~ ^http ]]; then
    content=$(curl -s "$target")
  elif [[ -f "$target" ]]; then
    content=$(cat "$target")
  else
    echo "[!] Skipping invalid target: $target"
    continue
  fi

  for sink in $(echo "$SINKS" | tr ',' '\n'); do
    if echo "$content" | grep -Ei "$sink" > /dev/null; then
      echo "[+] Sink '$sink' found in: $target"
      echo "$target" >> "$OUTPUT"
      break
    fi
  done
done

echo ""
echo "[✓] DOM sink scan complete."
echo "[→] Candidates saved to: $OUTPUT"
echo "[→] Feed into Dalfox or LOXS for exploitation."
