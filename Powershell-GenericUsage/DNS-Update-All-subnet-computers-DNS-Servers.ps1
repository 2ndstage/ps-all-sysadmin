#Requires -Module ActiveDirectory
###########################################################################################################
# This script is intended to find AD computers with a certain IP prefix (on a certain subnet for example) #
# and replace their DNS server client settings using CIM.                                                 #
# It will also output a status for each server it is working on - results look like this:                 #
#                                                                                                         #
# Processing COMPUTER1                                                                                    #
# Finished Processing COMPUTER1                                                                           #
# Results: for COMPUTER1                                                                                  #
#                                                                                                         #
# InterfaceAlias ServerAddresses                                                                          #                                            
# -------------- ---------------                                                                          #                                             
# Ethernet       {10.100.100.11, 10.100.100.12}                                                           #
###########################################################################################################

###########################################################################################################
# Gather all non-disabled *Server* AD Computer objects with an IPv4 address on the floating network in an array 
# looking for only those that have an IPv4Address attribute starting with X.X.X.
###########################################################################################################
# ------CHANGE <X.X.X.*> to first 3 octets of subnet you want to affect - adjust for any non /24 subnets
# ------REMOVE " -and (OperatingSystem -Like "*server*")" or adjust if you want to look for a different OS type
$computer = @(Get-ADComputer -Filter {(Enabled -eq $True) -and (OperatingSystem -Like "*server*")} -Properties * | Where-object {$_.IPv4Address -Like "<X.X.X.*>"} | Select-Object -ExpandProperty Name)

###########################################################################################################
# Gather all network enabled network adapters - Start Foreach loop
###########################################################################################################
Foreach($computer in $computer){
	Write-host "Processing $computer" -ForegroundColor Red -BackgroundColor Yellow

###########################################################################################################
# Update DNS Servers to New DNS Servers using CIM
###########################################################################################################
	# Create a new CIM session
	$CIM = @(New-CimSession -ComputerName $computer)
	
	# Get Interface Index - Looking for Interface with DNS servers starting with a known IP
	# ------CHANGE <Y.*> to first octet of DNS Server IP
	$Int = @(Get-DnsClientServerAddress -CimSession $CIM | Where {$_.ServerAddresses -like "<Y.*>"} | Select-Object InterfaceIndex -ExpandProperty InterfaceIndex)
	
	# Set DNS servers for discovered interface with DNS Server A and B
	# ------CHANGE “<A.A.A.A>”,”<B.B.B.B>” to your primary and secondary DNS servers
	Set-DnsClientServerAddress -CIMSession $CIM -InterfaceIndex $Int -ServerAddresses (“<A.A.A.A>”,”<B.B.B.B>”)
	
	# Output results limiting results to interfaces that have DNS servers starting with
	# ------CHANGE <Z.*> to the first octet of the new DNS servers
	Write-host "Finished Processing $computer" -ForegroundColor White -BackgroundColor DarkGreen
	Write-Host "Results: for $computer"
	Get-DnsClientServerAddress -CimSession $CIM | Where-object {$_.ServerAddresses -like "<Z.*>"} | ft InterfaceAlias,ServerAddresses
###########################################################################################################
# End Foreach loop
###########################################################################################################
}