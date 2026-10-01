# verify.ps1 - Automated Verification Suite for File Metrics Checker (Menu Feature)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Running Automated Verification Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Compile check.java
Write-Host "`n[Step 1] Compiling check.java..." -ForegroundColor Yellow
$compileOutput = cmd.exe /c "javac check.java 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "COMPILATION FAILED!" -ForegroundColor Red
    Write-Host $compileOutput
    exit 1
}
Write-Host "Compilation successful." -ForegroundColor Green

# 2. Test Cases Definition
$testCases = @(
    @{
        Name = "Benchmark myFile.txt"
        File = "myFile.txt"
        ExpectedLines = 15
        ExpectedWords = 87
        ExpectedParagraphs = 3
        ExpectedMama = 0
    },
    @{
        Name = "Empty File (0 bytes)"
        File = "fixtures\empty.txt"
        ExpectedLines = 0
        ExpectedWords = 0
        ExpectedParagraphs = 0
        ExpectedMama = 0
    },
    @{
        Name = "Whitespace Only"
        File = "fixtures\whitespace_only.txt"
        ExpectedLines = 3
        ExpectedWords = 0
        ExpectedParagraphs = 0
        ExpectedMama = 0
    },
    @{
        Name = "Single Line (No EOF Newline)"
        File = "fixtures\single_line.txt"
        ExpectedLines = 1
        ExpectedWords = 8
        ExpectedParagraphs = 1
        ExpectedMama = 0
    },
    @{
        Name = "Consecutive Blank Lines"
        File = "fixtures\consecutive_blank_lines.txt"
        ExpectedLines = 12
        ExpectedWords = 25
        ExpectedParagraphs = 3
        ExpectedMama = 0
    },
    @{
        Name = "Mama Word Occurrences"
        File = "fixtures\mama_sample.txt"
        ExpectedLines = 7
        ExpectedWords = 36
        ExpectedParagraphs = 2
        ExpectedMama = 9
    }
)

function Run-MetricsCheck($filePath) {
    $output = @('A', 'B', 'C', 'D', 'Q') | cmd.exe /c "java check $filePath 2>&1"
    $lines = $null
    $words = $null
    $paragraphs = $null
    $mama = $null

    foreach ($line in ($output -split "`r?`n")) {
        if ($line -match "^Lines:\s+(\d+)") { $lines = [int]$matches[1] }
        if ($line -match "^Words:\s+(\d+)") { $words = [int]$matches[1] }
        if ($line -match "^Paragraphs:\s+(\d+)") { $paragraphs = [int]$matches[1] }
        if ($line -match "^(?:Occurrences of `"Mama`"|Mama):\s+(\d+)") { $mama = [int]$matches[1] }
    }

    return @{ Lines = $lines; Words = $words; Paragraphs = $paragraphs; Mama = $mama }
}

$allPassed = $true
$totalTests = $testCases.Count
$passedTests = 0

Write-Host "`n[Step 2] Executing Metric Option Test Cases (A, B, C, D, Q)..." -ForegroundColor Yellow

foreach ($test in $testCases) {
    Write-Host "Testing: $($test.Name)... " -NoNewline
    $result = Run-MetricsCheck $test.File

    $linesOk = ($result.Lines -eq $test.ExpectedLines)
    $wordsOk = ($result.Words -eq $test.ExpectedWords)
    $paragraphsOk = ($result.Paragraphs -eq $test.ExpectedParagraphs)
    $mamaOk = ($result.Mama -eq $test.ExpectedMama)

    if ($linesOk -and $wordsOk -and $paragraphsOk -and $mamaOk) {
        Write-Host "PASS" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "FAIL" -ForegroundColor Red
        Write-Host "  Expected -> Lines: $($test.ExpectedLines), Words: $($test.ExpectedWords), Paragraphs: $($test.ExpectedParagraphs), Mama: $($test.ExpectedMama)" -ForegroundColor Red
        Write-Host "  Got      -> Lines: $($result.Lines), Words: $($result.Words), Paragraphs: $($result.Paragraphs), Mama: $($result.Mama)" -ForegroundColor Red
        $allPassed = $false
    }
}

Write-Host "`n[Step 3] Error Handling Test..." -ForegroundColor Yellow
Write-Host "Testing missing file handling... " -NoNewline
$errOutput = cmd.exe /c "java check non_existent_file_xyz.txt 2>&1"
$errString = $errOutput -join "`n"
if ($errString -match "Error: File 'non_existent_file_xyz.txt' not found") {
    Write-Host "PASS" -ForegroundColor Green
    $passedTests++
    $totalTests++
} else {
    Write-Host "FAIL" -ForegroundColor Red
    Write-Host "  Got -> $errString" -ForegroundColor Red
    $allPassed = $false
    $totalTests++
}

Write-Host "`n[Step 4] Interactive Menu Specific Tests..." -ForegroundColor Yellow

# 4.1 Case Insensitivity (lowercase a, b, c, d, q)
Write-Host "Testing lowercase input tolerance (a, b, c, d, q)... " -NoNewline
$lowerOutput = @('a', 'b', 'c', 'd', 'q') | cmd.exe /c "java check fixtures\mama_sample.txt 2>&1"
$lowerString = $lowerOutput -join "`n"
if ($lowerString -match "Words:\s+36" -and $lowerString -match "Lines:\s+7" -and $lowerString -match "Paragraphs:\s+2" -and $lowerString -match "(?:Occurrences of `"Mama`"|Mama):\s+9" -and $lowerString -match "Goodbye!") {
    Write-Host "PASS" -ForegroundColor Green
    $passedTests++
    $totalTests++
} else {
    Write-Host "FAIL" -ForegroundColor Red
    $allPassed = $false
    $totalTests++
}

# 4.2 Invalid Input Handling
Write-Host "Testing invalid input handling (unknown option)... " -NoNewline
$invalidOutput = @('invalid_option', 'Q') | cmd.exe /c "java check fixtures\mama_sample.txt 2>&1"
$invalidString = $invalidOutput -join "`n"
if ($invalidString -match "Invalid selection\. Please choose A, B, C, D, or Q\.") {
    Write-Host "PASS" -ForegroundColor Green
    $passedTests++
    $totalTests++
} else {
    Write-Host "FAIL" -ForegroundColor Red
    $allPassed = $false
    $totalTests++
}

# 4.3 EOF Graceful Exit
Write-Host "Testing graceful exit on EOF (no Quit command)... " -NoNewline
$eofOutput = cmd.exe /c "echo. | java check fixtures\mama_sample.txt 2>&1"
$eofExitCode = $LASTEXITCODE
if ($eofExitCode -eq 0) {
    Write-Host "PASS" -ForegroundColor Green
    $passedTests++
    $totalTests++
} else {
    Write-Host "FAIL (exit code $eofExitCode)" -ForegroundColor Red
    $allPassed = $false
    $totalTests++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Verification Summary: $passedTests / $totalTests Passed" -ForegroundColor $(if ($allPassed) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan

if (-not $allPassed) {
    exit 1
}
