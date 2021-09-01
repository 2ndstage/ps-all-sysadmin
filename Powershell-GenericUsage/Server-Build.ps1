# Server-Build.ps1
# Enables:  RDP and firewall exceptions, SMB signing enforced for server/workstation, Strong ciphers
# Disables: Downloaded Maps Manager Service, Geolocation Service, Xbox services and tasks, SMBv1 (removes feature too), SSL2 and 3, Weak ciphers
# In progress: 
# Determine OS and skip SMBv1, Xbox if Server 2019.
# Ask for timezone and set. 
# Menu to run one or all available items for OS.
# Define Functions

# Function - Enable RDP and firewall rules
    Write-Host "Enabling RDP and related Firewall Rules" -ForegroundColor Red -BackgroundColor Yellow
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
    Get-NetFirewallRule | Where-Object {$_.DisplayGroup -eq "Remote Desktop"} | Enable-NetfirewallRule
    ## !!Need some error checking and related Write-Host command if a function doesn't work!!
    Write-Host "RDP Enabled and allowed through Firewall" -ForegroundColor White -BackgroundColor DarkGreen

# Function - Enforce SMB signing
    Write-Host "Enforcing SMB Signing for Server and Workstation settings" -ForegroundColor Red -BackgroundColor Yellow
    Set-SmbServerConfiguration -EnableSecuritySignature $true -Force
    Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
    Set-SmbClientConfiguration -EnableSecuritySignature $true -Force
    Set-SmbClientConfiguration -RequireSecuritySignature $true -Force
    Write-Host "SMB Signing Enforced" -ForegroundColor White -BackgroundColor DarkGreen

# Function - Disable LLMNR and Netbios over TCP/IP
    Write-Host "Disabling LLMNR" -ForegroundColor Red -BackgroundColor Yellow

    # Following is from https://cantyouautomatethat.com/create-registry-keys-powershell/
    $RegKeyExists = 'HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient'
    $RegKeyPath = 'HKLM:\Software\Policies\Microsoft\Windows NT\'
    if(-not (Test-Path $RegKeyExists)){
        New-Item -Path $RegKeyPath -Name 'DNSClient' -Force
        New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient' -name "EnableMulticast" -value 0 -PropertyType DWord
    }
    Invoke-CimMethod -Query 'SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=1' -MethodName SetTcpipNetbios -Arguments @{TcpipNetbiosOptions=[uint32]2}
    Write-Host "LLMNR Disabled" -ForegroundColor White -BackgroundColor DarkGreen

# Function - Disable Downloaded maps manager, Geolocation services
        Write-Host "Disabling Maps and Geolocation services" -ForegroundColor Red -BackgroundColor Yellow
        Set-Service -Name "MapsBroker" -StartupType Disabled
        Set-Service -Name "lfsvc" -StartupType Disabled
        Write-Host "Maps/Geolocation Services Disabled" -ForegroundColor White -BackgroundColor DarkGreen

# 2016 only Function - Disable SMB v1 - will likely error out on Windows 2019, but leaving for now
## Warn about scanners if selected in menu?
    Write-Host "Disabling SMBv1" -ForegroundColor Red -BackgroundColor Yellow
    Set-SMBServerConfiguration -EnableSMB1Protocol $false -Force
    Remove-WindowsFeature FS-SMB1 -confirm
    Write-Host "SMBv1 Disabled" -ForegroundColor White -BackgroundColor DarkGreen

# 2016 only function - Disable Xbox services and scheduled tasks - will likely error out on Windows 2019, but leaving for now
    Write-Host "Disabling Xbox Services and Tasks" -ForegroundColor Red -BackgroundColor Yellow
    Get-Service | Where {$_.DisplayName -like "*xbox*"} | Set-Service -StartupType Disabled
    Get-ScheduledTask | Where {$_.DisplayName -like "*Xbl*"} | Disable-ScheduledTask
    Write-Host "Xbox Services/Tasks Disabled" -ForegroundColor White -BackgroundColor DarkGreen

# Function - Disable SSL3 and weak ciphers
# IN PROGRESS
# Disable SSL 2.0
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -name Enabled -value 0 -PropertyType "DWord"

# Disable SSL 3.0
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -name Enabled -value 0 -PropertyType "DWord"
    
# Secure access to Config directory (SAM Database compromise mitigation    
    icacls %windir%\system32\config\*.* /inheritance:e 
  
# Disable weak ciphers and enable strong ciphers
    # Disable weak cyphers
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Null"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Null" -name "Enabled" -value 0 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56" -name "Enabled" -value 0 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128" -name "Enabled" -value 0 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128" -name "Enabled" -value 0 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128" -name "Enabled" -value 0 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" -name "Enabled" -value 0 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128" -name "Enabled" -value 0 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128" -name "Enabled" -value 0 -PropertyType "Dword"

    # Enable strong cyphers
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" -name "Enabled" -value 1 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168" -name "Enabled" -value 1 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128" -name "Enabled" -value 1 -PropertyType "Dword"

    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256"
    md "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256"
    new-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256" -name "Enabled" -value 1 -PropertyType "Dword"