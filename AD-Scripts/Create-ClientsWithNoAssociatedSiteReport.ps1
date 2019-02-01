#Get Domain Controllers for current domain
$DCs = Get-ADGroupMember "Domain Controllers"
#Initiate the clients array
$Clients = @()
Foreach ($DC in $DCs) {
    #Define the netlogon.log path
    $NetLogonFilePath = "\\" + $DC.Name + "\C$\Windows\debug\netlogon.log"
    #Reading the content of the netlogon.log file
    try {$NetLogonFile = Get-Content -Path $NetLogonFilePath -ErrorAction Stop}
    catch {"Error reading $NetLogonFilePath"}
    foreach ($Line in $NetLogonFile) {
        #Splitting the line to isolate each variable
        $ClientData = $Line.split(' ')
        #Creating the client object
        $ClientObject = New-Object -TypeName PSObject
        Add-Member -InputObject $ClientObject -MemberType NoteProperty -Name 'Hostname' -Value $ClientData[5]
        Add-Member -InputObject $ClientObject -MemberType NoteProperty -Name 'IP' -Value $ClientData[6]
        Add-Member -InputObject $ClientObject -MemberType NoteProperty -Name 'DomainController' -Value $DC.Name
        Add-Member -InputObject $ClientObject -MemberType NoteProperty -Name 'Date' -Value $ClientData[0]
        $Clients += $ClientObject
     }
}
$UniqueClients = $Clients | Sort-Object -Property IP -Unique
$UniqueClients | Out-GridView -Title "Clients which are not mapped to any AD sites ($($UniqueClients.Count) in total)"