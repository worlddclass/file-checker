# verify.ps1 - Automated Verification Suite for File Metrics Checker

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
    $output = cmd.exe /c "java check $filePath 2>&1"
    $lines = $null
    $words = $null
    $paragraphs = $null
    $mama = $null

    foreach ($line in ($output -split "`r?`n")) {
        if ($line -match "^Lines:\s+(\d+)") { $lines = [int]$matches[1] }
        if ($line -match "^Words:\s+(\d+)") { $words = [int]$matches[1] }
        if ($line -match "^Paragraphs:\s+(\d+)") { $paragraphs = [int]$matches[1] }
        if ($line -match "^Mama:\s+(\d+)") { $mama = [int]$matches[1] }
    }

    return @{ Lines = $lines; Words = $words; Paragraphs = $paragraphs; Mama = $mama }
}

$allPassed = $true
$totalTests = $testCases.Count
$passedTests = 0

Write-Host "`n[Step 2] Executing Test Cases..." -ForegroundColor Yellow

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
    $allPassed = $false
    $totalTests++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Verification Summary: $passedTests / $totalTests Passed" -ForegroundColor $(if ($allPassed) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan

if (-not $allPassed) {
    exit 1
}
