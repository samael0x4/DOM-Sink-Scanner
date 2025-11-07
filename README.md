

# DOM Sink Scanner 
Advanced DOM-based XSS sink scanner with severity scoring, payload injection, and JS beautification.
![DOMX Demo](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExYmRnYnZ6b25saGRuaXJhcm5vbjkycGptaDE2NjgwemxwYTMyYnptNCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/bdV8sqnmTbKQyb3sRJ/giphy.gif)

## ✅ Features

- It scans all JS files listed in `all_js.txt`  
- Detects dangerous DOM sinks with severity scoring (HIGH / MEDIUM / LOW)  
- Beautifies JS if `--beauty` is used  
- Injects payload wrappers if `--inject` is used  
- Saves output in `.txt` or `.json` format based on your choice  
- Generates sink frequency stats in `sink_stats.txt`  
- Creates test files in `injected/` for manual validation  

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

