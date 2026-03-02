$csv = Import-Csv "nb5_kpath_descriptors-results/rashba_206_all_descriptors.csv" -Delimiter ","
$columns = $csv[0].PSObject.Properties.Name
$rmean_cols = $columns | Where-Object { $_ -match "r_mean" }

if ($rmean_cols) {
    Write-Host "Found columns with 'r_mean':"
    $rmean_cols | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "No columns containing 'r_mean' found"
}

Write-Host "`nTotal columns in CSV: $($columns.Count)"
