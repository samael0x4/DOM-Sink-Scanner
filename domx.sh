#!/bin/bash
# ============================
# DOM Sink Scanner v1.3
# ============================

cat <<'BANNER'
                                                                                                                
 ▄▄▄▄    ▄▄▄▄  ▄    ▄         ▄▄▄▄    ▀           █              ▄▄▄▄                                           
 █   ▀▄ ▄▀  ▀▄ ██  ██        █▀   ▀ ▄▄▄    ▄ ▄▄   █   ▄         █▀   ▀  ▄▄▄    ▄▄▄   ▄ ▄▄   ▄ ▄▄    ▄▄▄    ▄ ▄▄ 
 █    █ █    █ █ ██ █        ▀█▄▄▄    █    █▀  █  █ ▄▀          ▀█▄▄▄  █▀  ▀  ▀   █  █▀  █  █▀  █  █▀  █   █▀  ▀
 █    █ █    █ █ ▀▀ █            ▀█   █    █   █  █▀█               ▀█ █      ▄▀▀▀█  █   █  █   █  █▀▀▀▀   █    
 █▄▄▄▀   █▄▄█  █    █        ▀▄▄▄█▀ ▄▄█▄▄  █   █  █  ▀▄         ▀▄▄▄█▀ ▀█▄▄▀  ▀▄▄▀█  █   █  █   █  ▀█▄▄▀   █    
                                                                                                                
                                                                                                                

BANNER
# ============================
# DOM Sink Scanner v1.3 (with Bloody banner)
# Author: Samael_0x4 (updated)
# GitHub: https://github.com/samael0x4/DOM-Sink-Scanner/
# Features added in v1.3:
#  - Live payload injection mode (--inject)
#  - Sink frequency counting at end of scan
#  - Optional JS beautification for discovered JS blocks (--beautify)
#  - Improved JSON output handling
#  - Flag-driven run and safer parsing
# ============================


set -o pipefail

usage(){
  cat <<EOF
Usage: $0 <targets-file-or-url-list> [--inject] [--beautify] [--payloads <file>] [--outdir <dir>]

Positional:
  targets-file-or-url-list   File containing targets (one per line) OR a single URL starting with http(s) (will be treated as single target)

Flags:
  --inject                   Attempt live payload injection when sinks are found (will try simple reflected injections)
  --beautify                 Save and beautify inline JS or .js responses when possible
  --payloads <file>          Custom payloads file (one payload per line). If omitted, built-in payloads used
  --outdir <dir>             Output directory (default: dom_scan_output)
  -h, --help                 Show this help

Examples:
  $0 targets.txt
  $0 https://example.com --inject --beautify
EOF
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

TARGETS_ARG="$1"; shift || true
INJECT=0
BEAUTIFY=0
PAYLOADS_FILE=""
OUTDIR="dom_scan_output"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --inject) INJECT=1; shift ;;
    --beautify) BEAUTIFY=1; shift ;;
    --payloads) PAYLOADS_FILE="$2"; shift 2 ;;
    --outdir) OUTDIR="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "[!] Unknown option: $1"; usage ;;
  esac
done

mkdir -p "$OUTDIR"
TXT_OUT="$OUTDIR/dom_candidates.txt"
JSON_OUT="$OUTDIR/dom_candidates.json"
BEAUT_DIR="$OUTDIR/beautified_js"
mkdir -p "$BEAUT_DIR"
> "$TXT_OUT"
> "$JSON_OUT"

# === sinks map ===
declare -A SINKS=([
  "eval" ]="HIGH"
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

# sink counts
declare -A SINK_COUNTS=()

# results array (will be converted to proper JSON)
RESULTS=()

# default payloads
DEFAULT_PAYLOADS=("<script>alert(1)</script>" "\";alert(1);//" "'><img src=x onerror=alert(1)>" "\" onerror=alert(1)//")

# load custom payloads if provided
if [[ -n "$PAYLOADS_FILE" && -f "$PAYLOADS_FILE" ]]; then
  mapfile -t PAYLOADS < "$PAYLOADS_FILE"
else
  PAYLOADS=("${DEFAULT_PAYLOADS[@]}")
fi

# helper: beautify JS if possible
beautify_js(){
  local input="$1" outbase="$2"
  # try js-beautify (npm) or python jsbeautifier
  if command -v js-beautify >/dev/null 2>&1; then
    js-beautify -r -f "$input" -o "$outbase"
    return $?
  elif python3 -m jsbeautifier >/dev/null 2>&1 2>/dev/null; then
    python3 - <<PY > "$outbase"
import sys
from jsbeautifier import beautify
s = open('$input','r',encoding='utf-8',errors='ignore').read()
open('$outbase','w',encoding='utf-8').write(beautify(s))
PY
    return $?
  else
    # fallback: basic indentation using sed (very coarse)
    sed 's/>/>&\n/g' "$input" | sed 's/\s\+</\n</g' > "$outbase"
    return 0
  fi
}

# helper: safe curl fetch
fetch_content(){
  local target="$1"
  # set user-agent and timeout
  curl -L --max-time 15 -A "DOM-Sink-Scanner/1.3" -s "$target" || echo ""
}

# process single target content
process_target(){
  local target="$1"
  echo "[*] Checking: $target"
  local content
  content=$(fetch_content "$target")
  if [[ -z "$content" ]]; then
    echo "[!] Empty or failed to fetch: $target"
    return
  fi

  # optionally save inline scripts or .js response for beautify
  if [[ $BEAUTIFY -eq 1 ]]; then
    # if target ends with .js fetch and beautify directly
    if [[ "$target" =~ \.js($|\?) ]]; then
      tmpf="$BEAUT_DIR/$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g').js"
      echo "$content" > "$tmpf"
      beautify_js "$tmpf" "$tmpf.beautified.js" >/dev/null 2>&1 || true
      echo "[+] Beautified JS saved: $tmpf.beautified.js"
    else
      # extract inline <script>...</script> blocks
      # save each block as a file
      awk 'BEGIN{RS="<script";FS="</script>"} NR>1{print $0}' <<<"$content" | nl -ba | while read -r n block; do
        # remove leading > and attributes
        block=${block#*>}
        outfn="$BEAUT_DIR/$(echo "$target" | sed 's/[^a-zA-Z0-9]/_/g')_script_${n}.js"
        echo "$block" > "$outfn"
        beautify_js "$outfn" "$outfn.beautified.js" >/dev/null 2>&1 || true
        echo "[+] Saved inline script: $outfn.beautified.js"
      done
    fi
  fi

  # search for sinks
  for sink in "${!SINKS[@]}"; do
    if echo "$content" | grep -Ei "\b$sink\b" >/dev/null; then
      severity="${SINKS[$sink]}"
      case "$severity" in
        HIGH) color="\e[1;31m" ;;
        MEDIUM) color="\e[1;33m" ;;
        LOW) color="\e[1;32m" ;;
      esac
      echo -e "${color}[+] $sink → $severity severity in: $target\e[0m"

      # increment sink count
      SINK_COUNTS["$sink"]=$(( ${SINK_COUNTS["$sink"]:-0} + 1 ))

      # record result
      RESULTS+=("{\"url\": \"$target\", \"sink\": \"$sink\", \"severity\": \"$severity\"}")
      echo "$target - $sink - $severity" >> "$TXT_OUT"

      # live injection (simple reflected check)
      if [[ $INJECT -eq 1 ]]; then
        echo "    [~] Attempting injections for sink: $sink"
        for p in "${PAYLOADS[@]}"; do
          # prepare payload (url-encoded for GET param)
          enc=$(python3 - <<PY 2>/dev/null
import urllib.parse,sys
print(urllib.parse.quote(sys.argv[1]))
PY
 "$p")
          # try to inject into existing query params if present, else append ?p=<payload>
          if [[ "$target" == *"?"* ]]; then
            inj_url=$(echo "$target" | sed -E "s/([&?])([^=]+)=([^&]*)/\1\2=$enc/")
            # if sed didn't change (no params), just append
            if [[ "$inj_url" == "$target" ]]; then
              inj_url="$target&injected=$enc"
            fi
          else
            inj_url="$target?injected=$enc"
          fi

          resp=$(fetch_content "$inj_url")
          if [[ -n "$resp" && "$resp" == *"${p//"/}"* ]]; then
            echo -e "    \e[1;31m[!] Payload reflected: $p -> $inj_url\e[0m"
            RESULTS+=("{\"url\": \"$target\", \"sink\": \"$sink\", \"severity\": \"$severity\", \"payload_reflected\": \"$p\", \"injection_url\": \"$inj_url\"}")
            echo "$target - $sink - injectable - $p" >> "$TXT_OUT"
            break
          fi
        done
      fi

      # break to avoid duplicate reporting for same target on first sink found (same behavior as v1.2)
      break
    fi
  done
}

# prepare targets list
TARGETS_LIST=()
if [[ "$TARGETS_ARG" =~ ^https?:// ]]; then
  TARGETS_LIST+=("$TARGETS_ARG")
elif [[ -f "$TARGETS_ARG" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')
    [[ -z "$line" ]] && continue
    TARGETS_LIST+=("$line")
  done < "$TARGETS_ARG"
else
  echo "[!] Targets file or URL not found: $TARGETS_ARG"
  exit 2
fi

# main loop
echo "[*] Starting scan on ${#TARGETS_LIST[@]} target(s)"
for t in "${TARGETS_LIST[@]}"; do
  process_target "$t"
done

# write JSON output
if [[ ${#RESULTS[@]} -gt 0 ]]; then
  printf "[\n  %s\n]\n" "$(printf "%s,\n  " "${RESULTS[@]}" | sed 's/,\n  $//')" > "$JSON_OUT"
else
  echo "[]" > "$JSON_OUT"
fi

# sink frequency report
echo ""
echo "[✓] Scan complete. Results saved to: $TXT_OUT and $JSON_OUT"
echo "\n[✓] Sink frequency summary:"
for s in "${!SINK_COUNTS[@]}"; do
  printf "  %-20s : %s\n" "$s" "${SINK_COUNTS[$s]}"
done | sort -k3 -n -r

# final notes
echo ""
echo "Notes:"
echo " - Injection is a simple reflected-check only (GET-based). It may produce false positives/negatives." 
echo " - Beautification attempts to use js-beautify (npm) or python jsbeautifier if available, otherwise uses a crude fallback." 
echo " - Make sure to have permission to test the targets before using --inject." 

echo "Done."
