Get-GPO -All | %{
    Get-GPOReport -name $_.displayname -ReportType html -path ("c:\GPOReports\"+$_.displayname+".html")
}