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
Subdomain lists :
```
# create https URLs from subdomains
awk '{ gsub(/^\\s+|\\s+$/,\"\",$0); if ($0) print "https://" $0 }' subdomain.txt | sort -u > subdomains_https.txt
./domx.sh subdomains_https.txt --inject
```
URLs File Lists : ( allurls.txt)
```
# Make sure every line is a full URL with scheme.
awk '{ if ($0 !~ /^https?:\/\//) print "https://" $0; else print $0 }' allurls.txt | sort -u > allurls_ready.txt
./domx.sh allurls_ready.txt --inject
```

JavaScript Files Lists :  ( allJS.txt )
```
./domx.sh  allJS.txt
```

Single URL, attempt injection and beautify inline JS
```
./domx.sh  https://example.com --inject --beautify
```

Use custom Payloads and change output dir
```
./domx.sh  targets.txt --inject --payloads mypayloads.txt --outdir my_scan
```

Default outputs (in dom_scan_output/)
```
dom_candidates.txt —   plain log lines (easy grep/read)
dom_candidates.json —   structured results (automation / parsing)
beautified_js/ —   saved & beautified JS blocks (if --beautify used)
```
