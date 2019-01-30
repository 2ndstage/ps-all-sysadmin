function Get-HostToIP($hostname) {   
    $error.clear()  
    Try{$result = [system.Net.Dns]::GetHostByName($hostname)}
    catch {$hostname}
    if (!$error){
        $result.AddressList | ForEach-Object {$hostname + ':::' + $_.IPAddressToString } 
        }
 }
Get-Content "c:\temp\Servers.txt" | ForEach-Object {(Get-HostToIP($_)) >> c:\temp\IPAddresses.txt}