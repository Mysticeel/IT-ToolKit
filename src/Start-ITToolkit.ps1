$modulePath = Join-Path $PSScriptRoot "Modules\SystemInformation.psm1"

Import-Module $modulePath -Force

Clear-Host

Write-Host ""
Write-Host "============================================"
Write-Host "               IT-Toolkit"
Write-Host "        Windows Support Toolkit"
Write-Host "============================================"
Write-Host ""

Write-Host "Collecting system information..."
Write-Host ""

$systemInfo = Get-ITSystemInformation

$systemInfo | Format-List