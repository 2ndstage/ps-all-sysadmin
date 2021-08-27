$reportFile = "c:\GPOReports\GPOLinksAndWMIFilters.csv"
Set-Content -Path $reportFile -Value ("GPO Name,# Links,Link Path,Enabled,No Override,WMI Filter")
$gpmc = New-Object -ComObject GPMgmt.GPM
$constants = $gpmc.GetConstants()
Get-GPO -All | %{
    [int]$counter = 0
    [xml]$report = $_.GenerateReport($constants.ReportXML)
    try
    {
        $wmiFilterName = $report.gpo.filtername
    }
    catch
    {
        $wmiFilterName = "none"
    }
    $report.GPO.LinksTo | % {
        if ($_.SOMPath -ne $null)
        {
            $counter += 1
            add-Content -Path $reportFile -Value ($report.GPO.Name + "," + $report.GPO.linksto.Count + "," + $_.SOMPath + "," + $_.Enabled + "," + $_.NoOverride + "," + $wmiFilterName)
        }
    }
    if ($counter -eq 0)
    {
        add-Content -Path $reportFile -Value ($report.GPO.Name + "," + $counter + "," + "NO LINKS" + "," + "NO LINKS" + "," + "NO LINKS")
    }
}