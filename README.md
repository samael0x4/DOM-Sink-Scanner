# DOM Sink Scanner 
Advanced DOM-based XSS sink scanner with severity scoring, payload injection, and JS beautification.

## Features
-✅ It scans all JS files listed in `all_js.txt`
-✅ Detects dangerous DOM sinks with severity scoring (HIGH / MEDIUM / LOW)
-✅ Beautifies JS if `--beauty` is used
-✅ Injects payload wrappers if `--inject` is used
-✅ Saves output in `.txt` or `.json` format based on your choice
-✅ Generates sink frequency stats in `sink_stats.txt`
-✅ Creates test files in `injected/` for manual validatio


## Requirements
- `js-beautify` (for `--beauty` flag)
```
  pip install jsbeautifier
```

## 📥 Input
A file containing JS URLs files:


## 🧪 Installation  &  Usage :
```
chmod +x domx.sh
```
```
./domx.sh all_js.txt --inject --beauty
```

## 📤 Output :
```
- dom_candidates.txt or dom_candidates.json → feed into Dalfox or LOXS
- sink_stats.txt → frequency summary
- injected/*.html → payload test wrappers (if --inject used)
```

## 🧠 Next Steps :
Feed dom_candidates.txt into:
```
dalfox pipe --deep-dom --custom-payload payloads/dom.txt
python loxs.py --input dom_candidates.txt --payload payloads/dom.txt
```

