Import-Module ActiveDirectory
$reportFile = "c:\GPOReports\OUsWithBlockInherit.csv"
set-Content -Path $reportFile -Value ("Block Inheritance OU Path")
Get-ADOrganizationalUnit -SearchBase "DC=Your,DC=Domain" -Filter * | Get-GPInheritance | Where-Object { $_.GPOInheritanceBlocked } | %{
    add-Content -Path $reportFile -Value ($_.path)
}