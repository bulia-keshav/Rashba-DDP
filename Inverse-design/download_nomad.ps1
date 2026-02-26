Param(
    [string]$JsonPath = "$PSScriptRoot/../ss_2d_materials.json",
    [string]$OutputRoot = "$PSScriptRoot"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedJson = Resolve-Path -Path $JsonPath
$resolvedOutput = Resolve-Path -Path $OutputRoot

Write-Host "Reading JSON from $resolvedJson" -ForegroundColor Cyan

$data = Get-Content -Path $resolvedJson -Raw | ConvertFrom-Json

function Download-FileSafe {
    param(
        [string]$Url,
        [string]$OutPath
    )

    if (Test-Path -Path $OutPath) {
        $info = Get-Item -Path $OutPath
        if ($info.Length -gt 0) {
            Write-Host "Skip existing $OutPath ($($info.Length) bytes)" -ForegroundColor DarkYellow
            return
        }

        Write-Host "Re-downloading empty file $OutPath" -ForegroundColor Yellow
    }

    Invoke-WebRequest -Uri $Url -OutFile $OutPath -UseBasicParsing
}

$processed = 0
foreach ($item in $data) {
    if (-not $item._id) { continue }

    $formula, $uid = $item._id -split '-', 2
    if (-not $uid) { $uid = '' }
    $folderName = if ($uid) { "$formula-$uid" } else { "$formula" }

    $target = Join-Path -Path $resolvedOutput -ChildPath $folderName
    New-Item -ItemType Directory -Path $target -Force | Out-Null

    $urls = @($item.NOMAD_files)
    if (-not $urls -or $urls.Count -eq 0) { continue }

    foreach ($url in $urls) {
        $fileName = Split-Path -Path $url -Leaf
        $outPath = Join-Path -Path $target -ChildPath $fileName

        try {
            Download-FileSafe -Url $url -OutPath $outPath
        }
        catch {
            Write-Warning "Failed to download $url -> $outPath : $_"
        }
    }

    $processed += 1
}

Write-Host "Processed $processed entries into $resolvedOutput" -ForegroundColor Green
