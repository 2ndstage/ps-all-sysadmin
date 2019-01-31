#Explain script
Write-host "This script will return the usernmae, account status, and forwarding address if there is one"

#Import AD so samaccountname works
Import-Module Activedirectory

#Settings for file ouput
$fLocation = "D:\Exchange Reports\"

#Get OU
$OU = Read-Host -Prompt "Input the OU name to search: (0202 - Dev Bank)"

#create File to write report to:
$fName = $fLocation+$OU+".txt"
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

#Get users
$users = get-aduser -searchbase "OU=$OU,OU=Hosted Exchange Customers,DC=CSIDMZ,DC=local" -Filter * | select name, samaccountname, enabled

#Loop through users to get info
$output = foreach ($user in $users)
{
    #Get the forwarding address on the mailbox
    $fwd = (get-mailbox -Identity $user.samaccountname -ErrorAction silentlycontinue).forwardingaddress

    if($fwd)
    {
    #Get the SMTP of the forwarding address if it exists
    $PrimarySMTP =  (get-Recipient $fwd).PrimarySMTPAddress
    }
    else{$PrimarySMTP = ""}

    #Create custom object to export CSV with all info.
    New-Object -TypeName PSCustomObject -Property @{
        User= $User.Name
        Enabled = $user.Enabled
        ForwardingAddress= $PrimarySMTP}
}

$output >> $fname 
Write-Host "Your file can be found at " $fname -ForegroundColor DarkGreen