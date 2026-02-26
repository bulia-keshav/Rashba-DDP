# Script to organize compound folders based on CSV UIDs

# Define paths
$baseDir = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $baseDir "Data"
$inverseDir = $PSScriptRoot

# Read CSVs and extract UIDs
Write-Host "Reading CSV files..." -ForegroundColor Cyan

$dresselhaus_uids = @{}
$highorder_uids = @{}
$rashba_uids = @{}
$zeeman_uids = @{}

# Read dresselhaus.csv
$dresselhaus_data = Import-Csv (Join-Path $dataDir "dresselhaus.csv")
foreach ($row in $dresselhaus_data) {
    $dresselhaus_uids[$row.uid] = $true
}
Write-Host "Dresselhaus UIDs: $($dresselhaus_uids.Count)" -ForegroundColor Green

# Read high_order.csv
$highorder_data = Import-Csv (Join-Path $dataDir "high_order.csv")
foreach ($row in $highorder_data) {
    $highorder_uids[$row.uid] = $true
}
Write-Host "High-order UIDs: $($highorder_uids.Count)" -ForegroundColor Green

# Read rashba.csv
$rashba_data = Import-Csv (Join-Path $dataDir "rashba.csv")
foreach ($row in $rashba_data) {
    $rashba_uids[$row.uid] = $true
}
Write-Host "Rashba UIDs: $($rashba_uids.Count)" -ForegroundColor Green

# Read zeeman.csv
$zeeman_data = Import-Csv (Join-Path $dataDir "zeeman.csv")
foreach ($row in $zeeman_data) {
    $zeeman_uids[$row.uid] = $true
}
Write-Host "Zeeman UIDs: $($zeeman_uids.Count)" -ForegroundColor Green

# Create category folders
Write-Host "`nCreating category folders..." -ForegroundColor Cyan
$folders = @("dresselhaus", "high_order", "rashba", "zeeman")
foreach ($folder in $folders) {
    $folderPath = Join-Path $inverseDir $folder
    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
        Write-Host "Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "Already exists: $folder" -ForegroundColor Yellow
    }
}

# Get all compound folders (excluding the category folders and the script)
Write-Host "`nOrganizing compound folders..." -ForegroundColor Cyan
$compoundFolders = Get-ChildItem -Path $inverseDir -Directory | Where-Object { 
    $_.Name -notin $folders -and $_.Name -ne "download_nomad.ps1"
}

$stats = @{
    dresselhaus = 0
    high_order = 0
    rashba = 0
    zeeman = 0
    unmatched = 0
}

foreach ($folder in $compoundFolders) {
    # Extract UID from folder name (format: Formula-uid)
    $parts = $folder.Name -split '-'
    if ($parts.Count -ge 2) {
        $uid = $parts[-1]  # Get last part as UID
        
        $moved = $false
        
        # Check which category the UID belongs to
        if ($dresselhaus_uids.ContainsKey($uid)) {
            $destPath = Join-Path $inverseDir "dresselhaus\$($folder.Name)"
            Move-Item -Path $folder.FullName -Destination $destPath -Force
            $stats.dresselhaus++
            $moved = $true
            Write-Host "Moved $($folder.Name) -> dresselhaus" -ForegroundColor Gray
        }
        elseif ($highorder_uids.ContainsKey($uid)) {
            $destPath = Join-Path $inverseDir "high_order\$($folder.Name)"
            Move-Item -Path $folder.FullName -Destination $destPath -Force
            $stats.high_order++
            $moved = $true
            Write-Host "Moved $($folder.Name) -> high_order" -ForegroundColor Gray
        }
        elseif ($rashba_uids.ContainsKey($uid)) {
            $destPath = Join-Path $inverseDir "rashba\$($folder.Name)"
            Move-Item -Path $folder.FullName -Destination $destPath -Force
            $stats.rashba++
            $moved = $true
            Write-Host "Moved $($folder.Name) -> rashba" -ForegroundColor Gray
        }
        elseif ($zeeman_uids.ContainsKey($uid)) {
            $destPath = Join-Path $inverseDir "zeeman\$($folder.Name)"
            Move-Item -Path $folder.FullName -Destination $destPath -Force
            $stats.zeeman++
            $moved = $true
            Write-Host "Moved $($folder.Name) -> zeeman" -ForegroundColor Gray
        }
        
        if (-not $moved) {
            Write-Host "No match found for: $($folder.Name) (UID: $uid)" -ForegroundColor Red
            $stats.unmatched++
        }
    }
}

# Print summary
Write-Host "`n========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Dresselhaus: $($stats.dresselhaus) folders" -ForegroundColor Green
Write-Host "High-order: $($stats.high_order) folders" -ForegroundColor Green
Write-Host "Rashba: $($stats.rashba) folders" -ForegroundColor Green
Write-Host "Zeeman: $($stats.zeeman) folders" -ForegroundColor Green
Write-Host "Unmatched: $($stats.unmatched) folders" -ForegroundColor $(if ($stats.unmatched -gt 0) { "Red" } else { "Green" })
Write-Host "=============================" -ForegroundColor Cyan
