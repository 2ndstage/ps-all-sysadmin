$XP = Get-ADComputer -Filter {OperatingSystem -like "*XP*"} `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Where-Object {$_.whenChanged -gt $((Get-Date).AddDays(-90))} |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
          Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        @{name='Owner';`
          Expression={$_.nTSecurityDescriptor.Owner}}, `
        DistinguishedName



        ####Export to CSV
        ##  $XP | Export-CSV .\xp.csv

        ###Export to Gridview
        ##  $XP | Out-GridView
        
        ###Count
        ### ($XP | Measure-Object).Count