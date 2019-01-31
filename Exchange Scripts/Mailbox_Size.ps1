#Settings for file ouput
$fLocation = "D:\Exchange Reports\"

#Get OU
$OU = Read-Host -Prompt "Input the OU name to search: (0202 - Dev Bank)"

#create File to write report to:
$fName = $fLocation+$OU+" Mailbox Size.csv"
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

Get-Mailbox -OrganizationalUnit "OU=$OU,OU=Hosted Exchange Customers,DC=CSIDMZ,DC=local" | 
Get-MailboxStatistics | select displayname, totalitemsize, itemcount | Export-Csv $fname

Write-host "Your file can be located at " $fname
