# Requirements Document: File Metrics Checker

## 1. Overview
The goal of this project is to develop a standalone Java program named `check.java` that analyzes a target text file named `myFile.txt` and calculates four primary metrics:
1. **Total number of lines**
2. **Total number of words**
3. **Total number of paragraphs**
4. **Total occurrences of the word "Mama"**

The program will output these statistics in a clear, user-friendly format to standard output.

---

## 2. Project & Environment Specifications
- **Target Source File:** `check.java`
- **Target Input File:** `myFile.txt`
- **Language / Runtime:** Java (OpenJDK 21+)
- **Dependencies:** Standard Java SE Library (`java.io`, `java.nio.file`, `java.util`) without external libraries.
- **Project Directory:** `C:\Users\ariel\.gemini\antigravity\scratch\file-checker`

---

## 3. Metric Definitions & Criteria

### 3.1 Line Count
- **Definition:** The count of lines in the file.
- **Details:**
  - Standard text lines separated by line breaks (`\n`, `\r\n`, or `\r`).
  - Empty lines (lines containing only whitespace or nothing) count towards the total line count.

### 3.2 Word Count
- **Definition:** The number of words in the text.
- **Details:**
  - A word is defined as a contiguous sequence of non-whitespace characters separated by whitespace (`\s+`).
  - Consecutive whitespace characters are treated as a single delimiter.
  - Empty or whitespace-only lines do not contribute any words.

### 3.3 Paragraph Count
- **Definition:** The number of paragraphs in the file.
- **Details:**
  - A paragraph is defined as a contiguous block of one or more non-empty text lines separated by one or more blank lines (empty or containing only whitespace).
  - Leading and trailing blank lines in the file do not count as paragraphs.
  - Multiple consecutive blank lines are treated as a single paragraph boundary.
  - A file with only whitespace or no content contains 0 paragraphs.

### 3.4 "Mama" Word Count
- **Definition:** The total number of times the word "Mama" appears in the file.
- **Details:**
  - Case-insensitive matching (`Pattern.CASE_INSENSITIVE`), matching "Mama", "mama", and "MAMA".
  - Uses regex word boundaries (`\bMama\b`) so occurrences surrounded by punctuation (such as `"Mama,"` or `(Mama)`) are counted accurately.
  - Substrings within other words (such as `Grandmama` or `Mamacita`) do not count.

---

## 4. Input & Output Requirements

### 4.1 Input Requirements
- Default input file: `myFile.txt` located in the same directory as the executable/source code.
- Graceful error handling if `myFile.txt` does not exist or is unreadable.

### 4.2 Output Requirements
- Results must be printed to the console (`System.out`).
- Clear and structured summary presentation.
- Example expected console output:
  ```text
  Analyzing file: myFile.txt
  ---------------------------------
  Lines:       15
  Words:       87
  Paragraphs:  3
  Mama:        0
  ---------------------------------
  ```

---

## 5. Edge Cases & Boundary Conditions
1. **Empty File (`0 bytes`):**
   - Lines: 0
   - Words: 0
   - Paragraphs: 0
2. **File with only whitespace / empty lines:**
   - Lines: number of line feeds
   - Words: 0
   - Paragraphs: 0
3. **Single Line without newline at EOF:**
   - Correctly counted as 1 line, appropriate word count, and 1 paragraph.
4. **Multiple Blank Lines between paragraphs:**
   - Must not artificially inflate the paragraph count.
5. **Missing Input File:**
   - Descriptive error message explaining that `myFile.txt` was not found, terminating gracefully without unhandled stack traces.

---

## 6. Execution & Build Instructions
- **Compilation:**
  ```powershell
  javac check.java
  ```
- **Execution:**
  ```powershell
  java check
  ```
