$reportFile = "c:\GPOReports\AllSettingsDisabledGpos.csv"
Set-Content -Path $reportFile -Value ("GPO Name,Settings")
Get-GPO -All | where{ $_.GpoStatus -eq "AllSettingsDisabled" } | % {
    add-Content -Path $reportFile -Value ($_.displayName+","+$_.gpoStatus)
}