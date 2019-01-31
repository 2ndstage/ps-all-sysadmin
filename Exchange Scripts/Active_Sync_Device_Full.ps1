#Script Created by Daniel Taylor 8/8/18

#Set Location for export:
$fLocation = "D:\Exchange Reports\"

#Get OU 
$OU = Read-host -Prompt "Input the OU name to search: (0202 - Dev Bank)"

#create File to write report to:
$fName = $fLocation+$OU+" ActiveSyncDevices.txt"
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

#Get ActiveSync and Mailbox data
$EASDevices = ""
$AllEASDevices = @()

$EASDevices = ""| select 'User','PrimarySMTPAddress','DeviceType','DeviceModel','DeviceOS', 'LastSyncAttemptTime','LastSuccessSync'
$EasMailboxes = Get-Mailbox -OrganizationalUnit "OU=$OU,OU=Hosted Exchange Customers,DC=CSIDMZ,DC=local" -ResultSize unlimited
foreach ($EASUser in $EasMailboxes) {
$EASDevices.user = $EASUser.displayname
$EASDevices.PrimarySMTPAddress = $EASUser.PrimarySMTPAddress.tostring()
    foreach ($EASUserDevices in Get-ActiveSyncDevice -Mailbox $EasUser.alias) {
$EASDeviceStatistics = $EASUserDevices | Get-ActiveSyncDeviceStatistics
    $EASDevices.devicetype = $EASUserDevices.devicetype
    $EASDevices.devicemodel = $EASUserDevices.devicemodel
    $EASDevices.deviceos = $EASUserDevices.deviceos
$EASDevices.lastsyncattempttime = $EASDeviceStatistics.lastsyncattempttime
$EASDevices.lastsuccesssync = $EASDeviceStatistics.lastsuccesssync
    $AllEASDevices += $EASDevices | select user,primarysmtpaddress,devicetype,devicemodel,deviceos,lastsyncattempttime,lastsuccesssync
    }
    }
$AllEASDevices = $AllEASDevices | sort user
$AllEASDevices
$AllEASDevices | Export-Csv $fname

write-host "The script completed successfully! The output file can be found at $fName" -ForeGroundColor Yellow