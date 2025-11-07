#!/bin/bash

# === CONFIG ===
TARGETS="$1"                       # List of JS URLs or HTML files
SINKS="document.write,innerHTML,eval,setTimeout,setInterval,location,src,href,onerror,onload"

# === LOOP ===
cat "$TARGETS" | while read target; do
  echo "[*] Scanning: $target"
  if [[ "$target" =~ ^http ]]; then
    content=$(curl -s "$target")
  else
    content=$(cat "$target")
  fi

  for sink in $(echo "$SINKS" | tr ',' '\n'); do
    if echo "$content" | grep -Ei "$sink"; then
      echo "[+] Sink found: $sink in $target"
    fi
  done
done
