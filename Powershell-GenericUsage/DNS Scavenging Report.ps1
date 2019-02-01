Function Create-DNSScavengingRecordsReport
{
    <#Creates a report with DNS records stale data.
    For any record, checks if:
    1)Stale record, responding to ping.
    2)Stale record, NOT responding to ping.
    3)Valid record, timestamp is updated (not stale).#>
    $DC = (Get-ADDomainController).Name
    $DNSRoot = (Get-ADDomain).DNSRoot
    $DNSRecords = Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $DNSRoot
    $DNSZoneAgingIntervals = (Get-DnsServerZoneAging -ComputerName $DC -ZoneName $DNSRoot).RefreshInterval + (Get-DnsServerZoneAging -ComputerName $DC -ZoneName $DNSRoot).NoRefreshInterval
    $DateThershold = (Get-Date).AddDays(-($DNSZoneAgingIntervals.Days))
    $DNSArray = @()
    ForEach ($DNSRecord in $DNSRecords)
    {
        If ($DNSRecord.RecordType -eq "A" -and $DNSRecord.Timestamp -ne $Null -and $DNSRecord.Hostname -ne "@" -and $DNSRecord.HostName -ne "DomainDnsZones" -and $DNSRecord.HostName -ne "ForestDnsZones")
        {
            Write-Host "Checking the record $($DNSRecord.Hostname).$DNSRoot"
            $Computer = $DNSRecord.HostName
            $ComputerIP = $DNSRecord.RecordData.IPv4Address.IPAddressToString
            $ComputerOS = "Null"
            Try
            {
                $ADComputer = Get-ADComputer $Computer -Properties OperatingSystem -ErrorAction Stop
                $ComputerOS = $ADComputer.OperatingSystem
            }
            Catch
            {
                Write-Host "The computer object could not be retreived from Active Directory. Skip." -ForegroundColor yellow
            }
            $Ping = Test-Connection -ComputerName $DNSRecord.HostName -Count 1 -ErrorAction SilentlyContinue
            $DNSObject = New-Object -TypeName PSObject
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'Hostname' -Value $Computer
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'IP' -Value $ComputerIP
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'Timestamp' -Value $DNSRecord.Timestamp
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'OS' -Value $ComputerOS
            If (($DNSRecord.Timestamp) -lt $DateThershold)
            {
                If ($Ping)
                {
                    $Status = "Stale record, responding to ping"
                }
                Else
                {
                    $Status = "Stale record, NOT responding to ping" 
                }
            }
            Else
            {
                 $Status = "Updated record"
            }
            Add-Member -InputObject $DNSObject -MemberType 'NoteProperty' -Name 'Status' -Value $Status
            $DNSArray += $DNSObject
        }
    }
    $DNSArray | Out-GridView -Title "DNS Records - Stale Report for $DNSRoot Zone (Querying $DC DNS Server)"
}