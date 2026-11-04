param(
    [string]$Design = "baseline",
    [string]$Port = "COM17"
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " >>> RUNNING AUTOMATED 3-IMAGE TRIAD FOR: $Design ($Port) <<<" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

python scripts/run_variant_triad.py --design $Design --port $Port

