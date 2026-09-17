# File Metrics Checker (`check.java`) - v1.0.0

A standalone Java tool that analyzes any specified text file (defaulting to `myFile.txt`) and calculates:
- Total **Lines**
- Total **Words**
- Total **Paragraphs**

---

## Requirements
- **Java SE Development Kit (JDK) 21+**
- **PowerShell** or terminal environment

---

## Project Structure
```text
file-checker/
├── .gitignore             # Git ignore configuration for Java
├── README.md              # Project documentation and guide
├── requirements.md        # Formal specifications for line/word/paragraph metrics
├── delivery_plan.md       # Branch and Pull Request delivery plan
├── check.java             # Main Java source code
├── myFile.txt             # Primary benchmark sample input file
├── fixtures/              # Boundary and edge-case test fixtures
│   ├── empty.txt
│   ├── whitespace_only.txt
│   ├── single_line.txt
│   └── consecutive_blank_lines.txt
└── verify.ps1             # Automated verification test suite
```

---

## Branch & Pull Request Delivery
Development is tracked across 6 distinct Pull Requests:
1. `docs/project-scaffolding` (PR #1): Setup `.gitignore`, `README.md`, `requirements.md`, `delivery_plan.md`
2. `feat/test-fixtures` (PR #2): Standard `myFile.txt` and boundary fixtures
3. `feat/core-metrics-engine` (PR #3): Line, word, and paragraph counting algorithms
4. `feat/cli-and-error-handling` (PR #4): User-friendly CLI summary and file error handling
5. `test/verification-suite` (PR #5): Automated test script (`verify.ps1`)
6. `release/v1.0.0` (PR #6): Version 1.0.0 finalization

---

## Compilation & Usage
```powershell
# Compile
javac check.java

# Run against default myFile.txt
java check

# Run against a custom file
java check path/to/customFile.txt
```

---

## Automated Verification
Run the regression test suite across all benchmark and boundary fixtures:
```powershell
powershell -ExecutionPolicy Bypass -File .\verify.ps1
```
