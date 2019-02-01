#Find Group Policies with Missing Permissions
Function Get-GPMissingPermissionsGPOs
{
   $MissingPermissionsGPOArray = New-Object System.Collections.ArrayList
   $GPOs = Get-GPO -all
   foreach ($GPO in $GPOs) {
        If ($GPO.User.Enabled) {
            $GPOPermissionForAuthUsers = Get-GPPermission -Guid $GPO.Id -All | select -ExpandProperty Trustee | ? {$_.Name -eq "Authenticated Users"}
            $GPOPermissionForDomainComputers = Get-GPPermission -Guid $GPO.Id -All | select -ExpandProperty Trustee | ? {$_.Name -eq "Domain Computers"}
            If (!$GPOPermissionForAuthUsers -and !$GPOPermissionForDomainComputers) {
                $MissingPermissionsGPOArray.Add($GPO)| Out-Null
            }
        }
    }
    If ($MissingPermissionsGPOArray.Count -ne 0) {
        Write-Warning  "The following Group Policy Objects do not grant any permissions to the 'Authenticated Users' or 'Domain Computers' groups:"
        foreach ($GPOWithMissingPermissions in $MissingPermissionsGPOArray) {
            Write-Host "'$($GPOWithMissingPermissions.DisplayName)'"
        }
    }
    Else {
        Write-Host "All Group Policy Objects grant required permissions. No issues were found." -ForegroundColor Green
    }
}