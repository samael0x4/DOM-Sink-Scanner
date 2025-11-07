# DOM Sink Scanner

Small CLI scanner that finds DOM sinks in JavaScript files and can perform simple reflected injection checks.  
Features: sink detection, sink frequency summary, optional live payload injection.

**Quick features**
- Detects sinks like `eval`, `innerHTML`, `document.write`, etc.
- Counts frequency of each sink and prints a summary.
- `--inject` performs basic GET-based reflected injection checks (see note).
- `--beautify` saves & attempts to beautify inline/.js scripts for inspection.
- Outputs: plain text and structured JSON.

**Required**
bash, curl, grep, awk, sed, python3
Optional (better beautify): js-beautify (npm) or pip install jsbeautifier

**Usage (JS-only input)**
```
./domx.sh  all_js.txt
```
with injection custom payloads and custom output dir
```
./domx.sh all_js.txt --inject --payloads dom_payloads.txt --outdir my_scan
```
