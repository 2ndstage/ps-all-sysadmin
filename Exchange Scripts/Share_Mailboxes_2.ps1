#Settings for file ouput
$fLocation = "D:\Exchange Reports\O365 Reports\"

#Get OU
$OU = Read-Host -Prompt "Input the OU name to search: (0202 - Dev Bank)"

#create File to write report to:
$fName = $fLocation+$OU+" Shared Mailboxes.csv"
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
Write-host "Creating New File..." -ForeGroundColor darkgreen
New-Item $fName -type file

#get ou number
$quote = '"'
$ounumber = $OU.split(' ')[0]
$userou = $quote+"csidmz\*."+$ounumber+$quote

$access = @()


$users = Get-Mailbox -organizationalunit "OU=$OU,OU=Hosted Exchange Customers,DC=CSIDMZ,DC=local" -ResultSize Unlimited  

    foreach ($user in $users){
        $access =  Get-MailboxPermission -identity $user
                   Where-Object {($_.AccessRights -match "FullAccess")} 
                   }
 $access | select Identity, User | export-csv $fname

