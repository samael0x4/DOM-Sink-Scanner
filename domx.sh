#!/bin/bash

# ============================
# DOM Sink Scanner v1.2
# Author: Samael_0x4
# GitHub: https://github.com/samael0x4/DOM-Sink-Scanner/
# ============================


# === Banner ===
clear
echo -e "\e[1;32m"
echo "▗▄▄   ▗▄▖ ▗▄ ▄▖      ▗▄▖   █       ▗▖         ▗▄▖                               "
echo "▐▛▀█  █▀█ ▐█ █▌     ▗▛▀▜   ▀       ▐▌        ▗▛▀▜                                "
echo "▐▌ ▐▌▐▌ ▐▌▐███▌     ▐▙    ██  ▐▙██▖▐▌▟▛      ▐▙    ▟██▖ ▟██▖▐▙██▖▐▙██▖ ▟█▙  █▟█▌"
echo "▐▌ ▐▌▐▌ ▐▌▐▌█▐▌      ▜█▙   █  ▐▛ ▐▌▐▙█        ▜█▙ ▐▛  ▘ ▘▄▟▌▐▛ ▐▌▐▛ ▐▌▐▙▄▟▌ █▘"
echo "▐▌ ▐▌▐▌ ▐▌▐▌▀▐▌        ▜▌  █  ▐▌ ▐▌▐▛█▖         ▜▌▐▌   ▗█▀▜▌▐▌ ▐▌▐▌ ▐▌▐▛▀▀▘ █ "
echo "▐▙▄█  █▄█ ▐▌ ▐▌     ▐▄▄▟▘▗▄█▄▖▐▌ ▐▌▐▌▝▙      ▐▄▄▟▘▝█▄▄▌▐▙▄█▌▐▌ ▐▌▐▌ ▐▌▝█▄▄▌ █   "
echo "▝▀▀   ▝▀▘ ▝▘ ▝▘      ▀▀▘ ▝▀▀▀▘▝▘ ▝▘▝▘ ▀▘      ▀▀▘  ▝▀▀  ▀▀▝▘▝▘ ▝▘▝▘ ▝▘ ▝▀▀  ▀   "
echo -e "\e[0m"
echo "               ~ Samael_0x4 | Version: 1.2"
echo "               GitHub: https://github.com/samael0x4/DOM-Sink-Scanner/"
echo ""

# === Parse Flags ===
INJECT=false
BEAUTY=false
for arg in "$@"; do
  case "$arg" in
    --inject) INJECT=true ;;
    --beauty) BEAUTY=true ;;
  esac
done

# === Input File ===
TARGETS="$1"
if [[ ! -f "$TARGETS" ]]; then
  echo "[!] Input file not found: $TARGETS"
  exit 1
fi

# === Sink Definitions ===
declare -A SINKS=(
  ["eval"]="HIGH"
  ["document.write"]="HIGH"
  ["innerHTML"]="MEDIUM"
  ["outerHTML"]="MEDIUM"
  ["setTimeout"]="MEDIUM"
  ["setInterval"]="MEDIUM"
  ["location"]="LOW"
  ["src"]="LOW"
  ["href"]="LOW"
  ["onerror"]="MEDIUM"
  ["onload"]="MEDIUM"
  ["onmouseover"]="LOW"
  ["onfocus"]="LOW"
  ["onanimationstart"]="LOW"
)

# === Setup Output Files ===
TXT_OUT="dom_candidates.txt"
JSON_OUT="dom_candidates.json"
STATS_OUT="sink_stats.txt"
INJECT_DIR="injected"
> "$TXT_OUT"
> "$JSON_OUT"
> "$STATS_OUT"
mkdir -p "$INJECT_DIR"

# === Frequency Counter ===
declare -A COUNTS

# === Scan Loop ===
echo "[*] Scanning targets from: $TARGETS"
cat "$TARGETS" | while read target; do
  echo "[*] Checking: $target"

  # Fetch content
  if [[ "$target" =~ ^http ]]; then
    content=$(curl -s "$target")
  elif [[ -f "$target" ]]; then
    content=$(cat "$target")
  else
    echo "[!] Skipping invalid target: $target"
    continue
  fi

  # Beautify if enabled
  if $BEAUTY; then
    content=$(echo "$content" | js-beautify -)
  fi

  # Sink detection
  for sink in "${!SINKS[@]}"; do
    if echo "$content" | grep -Ei "$sink" > /dev/null; then
      severity="${SINKS[$sink]}"
      COUNTS["$sink"]=$((COUNTS["$sink"] + 1))

      # Color-coded output
      case "$severity" in
        HIGH) color="\e[1;31m" ;;   # Red
        MEDIUM) color="\e[1;33m" ;; # Yellow
        LOW) color="\e[1;32m" ;;    # Green
      esac
      echo -e "${color}[+] $sink → [$severity] : $target\e[0m"

      # Save results
      echo "$target" >> "$TXT_OUT"
      echo "{\"url\": \"$target\", \"sink\": \"$sink\", \"severity\": \"$severity\"}," >> "$JSON_OUT"

      # Inject payload if enabled
      if $INJECT; then
        fname=$(echo "$target" | md5sum | cut -d' ' -f1)
        echo "<!-- Sink: $sink -->" > "$INJECT_DIR/$fname.html"
        echo "<script>$sink('XSS_PAYLOAD')</script>" >> "$INJECT_DIR/$fname.html"
      fi

      break
    fi
  done
done

# === Sink Frequency Summary ===
echo "[*] Sink Frequency Summary:" | tee "$STATS_OUT"
for sink in "${!COUNTS[@]}"; do
  echo "  $sink: ${COUNTS[$sink]}" | tee -a "$STATS_OUT"
done

# === Output Format Selection ===
echo ""
echo "[✓] Scan complete."
echo "[?] Choose output format to save:"
echo "    1) .txt (plain list)"
echo "    2) .json (structured)"
read -p "Enter choice [1/2]: " choice

if [[ "$choice" == "2" ]]; then
  echo "[" > temp.json
  cat "$JSON_OUT" | sed '$ s/,$//' >> temp.json
  echo "]" >> temp.json
  mv temp.json "$JSON_OUT"
  echo "[→] Saved to: $JSON_OUT"
else
  echo "[→] Saved to: $TXT_OUT"
fi

echo "[→] Sink stats saved to: $STATS_OUT"
if $INJECT; then
  echo "[→] Injected test files saved to: $INJECT_DIR/"
fi                                                                              
