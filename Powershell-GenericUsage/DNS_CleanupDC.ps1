$dnszone = "_msdcs.xxx"

$ip = "x.x.x.x"

$fqdn = "xxx.internal"

$dnsrecords = Get-DnsServerResourceRecord -ZoneName $dnszone

$deadDC = $dnsrecords | Where-Object {$_.RecordData.IPv4Address -eq "x.x.x.x" -or $_.RecordData.NameServer -eq $ip -or $_.RecordData.DomainName -eq $fqdn}

$deadDC