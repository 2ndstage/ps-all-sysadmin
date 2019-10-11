param ( 
[string]$LDAPFilter = '(name=*)'
)

 

$wmiQuery = "select IPAddress, DefaultIPGateway from Win32_NetworkAdapterConfiguration where IPEnabled=TRUE and DHCPEnabled=FALSE"

 

$computers = (Get-ADComputer -LDAPFilter $LDAPFilter)
foreach ($computer in $computers) { 

 

    $networkAdapters = (Get-WmiObject -ErrorAction SilentlyContinue -ComputerName $computer.DNSHostName -Query $wmiQuery) 
    foreach ($networkAdapter in $networkAdapters) { 
        foreach ($ip in $networkAdapter.IPAddress) 
        { 
            if ($ip -match "\.") 
            { 
                Write-Host $($computer.DNSHostName), $ip } 
            }
    } 
}