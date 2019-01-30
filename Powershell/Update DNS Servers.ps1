$computer = Get-Content "c:\temp\workstations.csv"
Foreach($computer in $computer){
$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $computer |where{$_.IPEnabled -eq “TRUE”}
}
  Foreach($NIC in $NICs) {
$DNSServers = “8.8.8.8",”1.1.1.1" # set dns servers here
 $NIC.SetDNSServerSearchOrder($DNSServers)
 $NIC.SetDynamicDNSRegistration(“TRUE”)
}