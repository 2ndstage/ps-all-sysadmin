#Get Installed Roles on each Domain Controller
$DCsInForest = (Get-ADForest).Domains | % {Get-ADDomainController -Filter * -Server $_}
$DCsRolesArray = @()
foreach ($DC in $DCsInForest) {
    $DCRoles=""
    $Roles = Get-WindowsFeature -ComputerName $DC.HostName | Where-Object {$_.Installed -like "True" -and $_.FeatureType -like "Role"} | Select DisplayName
    foreach ($Role in $Roles) {
        $DCRoles += $Role.DisplayName +","
    }
    try {$DCRoles = $DCRoles.Substring(0,$DCRoles.Length-1)}
    catch {$DCRoles = "Server roles cannot be obtain"}
    $DCObject = New-Object -TypeName PSObject
    Add-Member -InputObject $DCObject -MemberType 'NoteProperty' -Name 'DCName' -Value $DC.HostName
    Add-Member -InputObject $DCObject -MemberType 'NoteProperty' -Name 'Roles' -Value $DCRoles
    $DCsRolesArray += $DCObject
}
$DCsRolesArray | Out-GridView