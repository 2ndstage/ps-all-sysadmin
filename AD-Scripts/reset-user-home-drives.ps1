# Reset user home drive directories - handy for server/file share cutovers.

# To reset home drives en masse (assumes everyone in AD is using the same server/path):

Get-ADUser -Filter * | Foreach-Object{

    $sam = $_.SamAccountName
    Set-ADuser -Identity $_ -HomeDrive "H:" -HomeDirectory "\\server\share\$sam"}


# To reset home drives based on OU:

get-aduser -filter 'Name -like "*"' -searchbase 'OU=Nested OU,OU=Nested OU,OU=Parent OU,DC=domain,DC=com' | Foreach-Object{

    $sam = $_.SamAccountName
    Set-ADuser -Identity $_ -HomeDrive "H:" -HomeDirectory "\\server\share\$sam"}

