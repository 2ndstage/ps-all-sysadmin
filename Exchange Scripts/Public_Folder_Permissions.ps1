<# Script created by Daniel Taylor 11-7-18

This pulls public folders permissions from exchange for a certian OU
#>

$OU = Read-host "Please enter ou: (0202 - Dev Bank)"
$Ident = "\"+$OU

Get-PublicFolder -Identity $Ident -Recurse | Get-PublicFolderClientPermission | Select Identity, User, AccessRights | Out-GridView

Write-host "Please Copy and paste from grid view to excel" -ForegroundColor Cyan