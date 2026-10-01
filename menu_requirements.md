# Requirements Document: Interactive Menu Feature

## 1. Overview
This document specifies the requirements for the **Interactive CLI Menu** feature on the `menu` branch for the File Metrics Checker (`check.java`).

The objective is to provide an interactive console menu that allows users to query individual metrics for a target text file on demand, rather than printing all statistics at once, and exit when done.

---

## 2. Target Branch & Environment
- **Branch:** `menu`
- **Source File:** [`check.java`](file:///c:/Users/ariel/.gemini/antigravity/scratch/file-checker/check.java)
- **Target File Analyzed:** `myFile.txt` (default) or user-specified via command-line argument
- **Base Requirements Reference:** [`requirements.md`](file:///c:/Users/ariel/.gemini/antigravity/scratch/file-checker/requirements.md)
- **Language / Runtime:** Java (OpenJDK 21+) using standard SE libraries (`java.util.Scanner`, `java.io.*`, `java.nio.*`)

---

## 3. Menu Specification & Options

Upon launch, after verifying target file accessibility, the program displays an interactive menu with the following exact options:

```text
=================================
       FILE METRICS MENU
=================================
A. show the amount of words in a file
B. show the amount of lines in a file
C. show the amount of paragraphs in a file
D. show the amount of times the word "Mama" appears in a file
Q. Quit
=================================
Enter your choice: 
```

### 3.1 Option Details

| Key | Option Label | Description | Calculation Rule |
| :---: | :--- | :--- | :--- |
| **A** | Show the amount of words in a file | Displays the total word count in the target file. | Contiguous non-whitespace tokens separated by `\s+`. |
| **B** | Show the amount of lines in a file | Displays the total line count in the target file. | Total lines separated by standard line breaks (`\r\n`, `\n`, `\r`). |
| **C** | Show the amount of paragraphs in a file | Displays the total paragraph count in the target file. | Non-empty text blocks delimited by one or more blank lines. |
| **D** | Show the amount of times the word "Mama" appears in a file | Displays total occurrences of the word "Mama". | Case-insensitive whole-word regex matching (`\bMama\b`). |
| **Q** | Quit | Terminates the program cleanly. | Exits loop and program with exit code 0. |

---

## 4. User Interaction & Control Flow

### 4.1 Interactive Loop
1. The program validates the input file existence and readability.
2. The menu options (`A`, `B`, `C`, `D`, `Q`) are presented to standard output.
3. The user is prompted for input via standard input (`System.in`).
4. Upon receiving a selection:
   - If **A**, **B**, **C**, or **D**: Output the requested metric clearly to the console, followed by returning to the menu prompt.
   - If **Q**: Print a farewell message (e.g., `Goodbye!`) and terminate execution.
   - If **Invalid Input**: Print an informative error message (e.g., `Invalid selection. Please choose A, B, C, D, or Q.`), and re-prompt.

### 4.2 Input Tolerance & Validation
- **Case-Insensitive Input:** Selections must accept both uppercase and lowercase letters (`a`/`A`, `b`/`B`, `c`/`C`, `d`/`D`, `q`/`Q`).
- **Whitespace Tolerance:** Leading and trailing whitespace around input must be trimmed automatically (e.g., `" a "` is treated as `"A"`).
- **Empty Input:** Pressing Enter without input should prompt the user again without crashing.
- **End-of-Stream (EOF) Handling:** If `System.in` closes or reaches EOF (e.g., redirected input or Ctrl+D/Ctrl+Z), the program must exit gracefully without throwing unhandled `NoSuchElementException`.

---

## 5. Output Formatting Requirements

### 5.1 Metric Results
When a user selects an option, the result must be clearly formatted before the menu is shown again.

Example outputs:
- **Option A:**
  ```text
  Words: 87
  ```
- **Option B:**
  ```text
  Lines: 15
  ```
- **Option C:**
  ```text
  Paragraphs: 3
  ```
- **Option D:**
  ```text
  Occurrences of "Mama": 9
  ```

---

## 6. Performance & Architecture
- **Metrics Parsing Strategy:** Metrics may be calculated once upon launch (or cached upon first read) to avoid redundant disk I/O when the user queries multiple metrics consecutively in the same session.
- **Modularity:** Maintain separate methods for:
  - File parsing / metric computation
  - Menu rendering
  - Input processing loop

---

## 7. Edge Cases & Error Handling
1. **File Not Found / Unreadable:** Output descriptive error message and exit prior to rendering the menu.
2. **Empty File (`0 bytes`):** Accurately report 0 for words, lines, paragraphs, and "Mama" counts.
3. **Invalid Choices:** Non-matching letters, numbers, or symbols should display an error and re-display the menu or prompt without terminating.
4. **Repeated Queries:** User can select any option multiple times and receive consistent results.
5. **Session Termination:** Choosing `Q` (or `q`) is the only standard exit condition during interactive use.

---

## 8. Verification & Acceptance Criteria
- [ ] Code compiles without warnings (`javac check.java`).
- [ ] Options `A`, `B`, `C`, `D`, and `Q` function as specified with case insensitivity.
- [ ] Invalid selections display an error message and continue the loop.
- [ ] Clean exit on `Q` / `q`.
- [ ] Clean exit on EOF from `System.in`.
