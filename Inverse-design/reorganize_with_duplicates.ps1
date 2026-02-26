# Script to reorganize folders with duplicates for overlapping UIDs

$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "Data"
$inverseDir = $PSScriptRoot

Write-Host "`nREORGANIZING WITH DUPLICATES..." -ForegroundColor Cyan
Write-Host "This will ensure each CSV's UIDs are in their respective folders" -ForegroundColor Yellow
Write-Host "Compounds appearing in multiple CSVs will be duplicated`n" -ForegroundColor Yellow

# First, move everything back to root
Write-Host "Step 1: Moving all folders back to root..." -ForegroundColor Cyan
$categoryFolders = @("dresselhaus", "high_order", "rashba", "zeeman", "unmatched")
foreach ($category in $categoryFolders) {
    $categoryPath = Join-Path $inverseDir $category
    if (Test-Path $categoryPath) {
        $folders = Get-ChildItem -Path $categoryPath -Directory
        foreach ($folder in $folders) {
            $destPath = Join-Path $inverseDir $folder.Name
            if (-not (Test-Path $destPath)) {
                Move-Item -Path $folder.FullName -Destination $destPath -Force
                Write-Host "  Moved $($folder.Name) back to root" -ForegroundColor Gray
            } else {
                Write-Host "  Skipped $($folder.Name) (already at root)" -ForegroundColor Yellow
            }
        }
    }
}

# Read CSVs and build UID mappings
Write-Host "`nStep 2: Reading CSV files and building UID mappings..." -ForegroundColor Cyan

$csvMappings = @{
    "dresselhaus" = @{}
    "high_order" = @{}
    "rashba" = @{}
    "zeeman" = @{}
}

$dresselhaus_data = Import-Csv (Join-Path $dataDir "dresselhaus.csv")
foreach ($row in $dresselhaus_data) {
    $csvMappings["dresselhaus"][$row.uid] = $true
}
Write-Host "  Dresselhaus: $($csvMappings['dresselhaus'].Count) unique UIDs" -ForegroundColor Green

$highorder_data = Import-Csv (Join-Path $dataDir "high_order.csv")
foreach ($row in $highorder_data) {
    $csvMappings["high_order"][$row.uid] = $true
}
Write-Host "  High-order: $($csvMappings['high_order'].Count) unique UIDs" -ForegroundColor Green

$rashba_data = Import-Csv (Join-Path $dataDir "rashba.csv")
foreach ($row in $rashba_data) {
    $csvMappings["rashba"][$row.uid] = $true
}
Write-Host "  Rashba: $($csvMappings['rashba'].Count) unique UIDs" -ForegroundColor Green

$zeeman_data = Import-Csv (Join-Path $dataDir "zeeman.csv")
foreach ($row in $zeeman_data) {
    $csvMappings["zeeman"][$row.uid] = $true
}
Write-Host "  Zeeman: $($csvMappings['zeeman'].Count) unique UIDs" -ForegroundColor Green

# Create category folders
Write-Host "`nStep 3: Creating category folders..." -ForegroundColor Cyan
foreach ($category in $categoryFolders) {
    $folderPath = Join-Path $inverseDir $category
    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
        Write-Host "  Created: $category/" -ForegroundColor Green
    }
}

# Get all compound folders at root (excluding category folders)
$allFolders = Get-ChildItem -Path $inverseDir -Directory | Where-Object { 
    $_.Name -notin $categoryFolders -and $_.Name -notlike "*.ps1"
}

Write-Host "`nStep 4: Organizing folders (with duplicates for overlaps)..." -ForegroundColor Cyan
Write-Host "Total folders to process: $($allFolders.Count)`n" -ForegroundColor Yellow

$stats = @{
    dresselhaus = 0
    high_order = 0
    rashba = 0
    zeeman = 0
    unmatched = 0
    duplicates = 0
}

foreach ($folder in $allFolders) {
    # Extract UID from folder name
    $parts = $folder.Name -split '-'
    if ($parts.Count -ge 2) {
        $uid = $parts[-1]
        
        $matchCount = 0
        $matched = $false
        
        # Check ALL categories and copy to each matching one
        foreach ($category in @("dresselhaus", "high_order", "rashba", "zeeman")) {
            if ($csvMappings[$category].ContainsKey($uid)) {
                $destPath = Join-Path $inverseDir "$category\$($folder.Name)"
                
                if ($matchCount -eq 0) {
                    # First match: Move
                    Move-Item -Path $folder.FullName -Destination $destPath -Force
                    Write-Host "  Moved $($folder.Name) -> $category/" -ForegroundColor Gray
                } else {
                    # Subsequent matches: Copy (duplicate)
                    Copy-Item -Path (Join-Path $inverseDir "$($prevCategory)\$($folder.Name)") -Destination $destPath -Recurse -Force
                    Write-Host "  Copied $($folder.Name) -> $category/ (duplicate)" -ForegroundColor Cyan
                    $stats.duplicates++
                }
                
                $stats[$category]++
                $matchCount++
                $matched = $true
                $prevCategory = $category
            }
        }
        
        # If not matched, move to unmatched folder
        if (-not $matched) {
            $destPath = Join-Path $inverseDir "unmatched\$($folder.Name)"
            # Check if folder still exists at root (it might have been moved already)
            if (Test-Path $folder.FullName) {
                Move-Item -Path $folder.FullName -Destination $destPath -Force
                Write-Host "  Moved $($folder.Name) -> unmatched/" -ForegroundColor Yellow
            }
            $stats.unmatched++
        }
    }
}

# Print summary
Write-Host "`n========== FINAL SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Dresselhaus: $($stats.dresselhaus) folders" -ForegroundColor Green
Write-Host "High-order: $($stats.high_order) folders" -ForegroundColor Green
Write-Host "Rashba: $($stats.rashba) folders" -ForegroundColor Green
Write-Host "Zeeman: $($stats.zeeman) folders" -ForegroundColor Green
Write-Host "Unmatched: $($stats.unmatched) folders" -ForegroundColor Yellow
Write-Host "Duplicates created: $($stats.duplicates)" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

Write-Host "`nNow each category folder contains ALL compounds from its CSV!" -ForegroundColor Green
