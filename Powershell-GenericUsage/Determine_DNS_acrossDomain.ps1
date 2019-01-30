$strFilter = "computer"

$objDomain = New-Object System.DirectoryServices.DirectoryEntry

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.SearchScope = "Subtree" 
$objSearcher.PageSize = 1000 

$objSearcher.Filter = "(objectCategory=$strFilter)"

$colResults = $objSearcher.FindAll()

foreach ($i in $colResults) 
    {
        $objComputer = $i.GetDirectoryEntry()
        $networkAdapter = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Property DNSServerSearchOrder -ComputerName $objComputer.Name -Filter "IPEnabled='True'"
        $computer = New-Object PSObject -Property @{
            ComputerName = $objComputer.Name
            DNSServer = $networkAdapter.DNSServerSearchOrder
        }

        Write-Output $computer
    }