# DOM Sink Scanner 

**What it is**  
Small CLI scanner that finds DOM sinks in HTML/JS and performs simple reflected injection checks.  
Features: sink detection, sink frequency summary, optional live payload injection.

**Quick features**
- Detects sinks like `eval`, `innerHTML`, `document.write`, etc.
- Counts frequency of each sink and prints a summary.
- `--inject` performs basic GET-based payload reflection checks.
- `--beautify` saves & attempts to beautify inline/.js scripts for inspection.
- Output: plain text and structured JSON.

**Usage**

```bash
# basic Scan from a File with targets (one per line)
./DOM-Sink-Scanner_v1.3.sh targets.txt
```

```
# Single URL, attempt injection and beautify inline JS
./DOM-Sink-Scanner_v1.3.sh https://example.com --inject --beautify
```

```
# use custom payloads and change output dir
./DOM-Sink-Scanner_v1.3.sh targets.txt --inject --payloads mypayloads.txt --outdir my_scan
```
