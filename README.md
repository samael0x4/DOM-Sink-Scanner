# DOM Sink Scanner 
Advanced DOM-based XSS sink scanner with severity scoring, payload injection, and JS beautification.

## 🚀 Features

- Sink severity scoring (HIGH / MEDIUM / LOW)
- Color-coded output (like Nuclei)
- `--inject` flag → auto-generate payload test wrappers
- `--beauty` flag → beautify JS before scanning
- Sink frequency summary (`sink_stats.txt`)
- Output format selection: `.txt` or `.json`
---

## 📦 Requirements
- `js-beautify` (for `--beauty` flag)
```
  pip install jsbeautifier
```

## 📥 Input
A file containing JS URLs files:


## 🧪 Installation &  Usage :
```
chmod +x domx.sh
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

## 🛠️ Coming Soon
- Auto JS extraction from HTML
- Sink severity ranking
- Headless browser execution



