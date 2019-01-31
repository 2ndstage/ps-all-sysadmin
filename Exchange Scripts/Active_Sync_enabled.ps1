<#
Script to lookup users utilizing ActiveSync based on Specific OU
Written By Daniel Taylor 12/2/16
Ver 1.0 - Script pulls names of users who have ActiveSync enabled.
#>

#Settings for file ouput
$fLocation = "D:\Exchange Reports\"

#Read OU imput from console:
$OU = Read-Host -Prompt "Input the OU name to search: (0202 - Dev Bank)"

#create File to write report to:
$fName = $fLocation+$OU+" ActiveSyncEnabled.txt"
$test = test-path $fName
    if ($test -eq $True)
        {
            write-host "Removing Old File..." -ForeGroundColor Red
            Remove-Item $fName
        }
    #Else
        #{
            #New-Item $fName -type file
        #}
Write-host "Creating New File..." -ForeGroundColor Green
New-Item $fName -type file


#lookup users based on the OU

Get-CASMailbox -OrganizationalUnit "OU=$OU,OU=Hosted Exchange Customers,DC=CSIDMZ,DC=local" -ResultSize unlimited | ft name,activesyncenabled -autosize >>$fname

foreach ($user in $Ulist)
    {
        $aSyncUser = get-activesyncdevice -mailbox $user.SAMAccountName -ErrorAction SilentlyContinue |ft name, activesyncenabled -HideTableHeaders 

        if ($aSyncUser -ne $null)
            {
                $deviceID = $aSyncUser | out-string
                $Content = "User: $user $deviceID"
                Add-Content $fName $Content
            }
    } 


    write-host "The script completed successfully! The output file can be found at $fName" -ForeGroundColor Yellow