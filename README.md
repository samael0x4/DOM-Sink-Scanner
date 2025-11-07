# DOM Sink Scanner 
Small CLI scanner that finds DOM sinks in HTML/JS and performs simple reflected injection checks.  
Features: sink detection, sink frequency summary, optional live payload injection.

**Quick features**
- Detects sinks like `eval`, `innerHTML`, `document.write`, etc.
- Counts frequency of each sink and prints a summary.
- `--inject` performs basic GET-based payload reflection checks.
- `--beautify` saves & attempts to beautify inline/.js scripts for inspection.
- Output: plain text and structured JSON.

**Required**
```
bash, curl, grep, awk, sed, python3
Optional (better beautify): js-beautify (npm) or pip install jsbeautifier
```


**Usage**

Basic Scan from a File with targets (one per line)
```bash
./domx.sh  targets.txt
```

Single URL, attempt injection and beautify inline JS
```
./domx.sh  https://example.com --inject --beautify
```

use custom Payloads and change output dir
```
./domx.sh  targets.txt --inject --payloads mypayloads.txt --outdir my_scan
```

Default outputs (in dom_scan_output/)
```
dom_candidates.txt —   plain log lines (easy grep/read)
dom_candidates.json —   structured results (automation / parsing)
beautified_js/ —   saved & beautified JS blocks (if --beautify used)
```
