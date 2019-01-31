#Script Created by Daniel Taylor 8/16/18

#Set Location for export:
$fLocation = "D:\Exchange Reports\"

#Get OU 
$OU = Read-host -Prompt "Input the OU name to search: (0202 - Dev Bank)"

#create File to write report to:
$fName = $fLocation+$OU+" PrimarySMTP.txt"
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

get-mailbox -organizationalunit "OU=$OU,OU=Hosted Exchange Customers,DC=csidmz,DC=local" | select name, primarysmtpaddress | sort name | export-csv $fname

write-host "The script completed successfully! The output file can be found at $fName" -ForeGroundColor Yellow