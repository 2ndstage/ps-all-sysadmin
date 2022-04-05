# Server-Build-Verification.ps1

# Function - Verify RDP and firewall rules
    Write-Host "Verify RDP and related Firewall Rules" -ForegroundColor Red -BackgroundColor Yellow
    Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections"
    Get-NetFirewallRule | Where-Object {$_.DisplayGroup -eq "Remote Desktop"} 
    
# Function - Verify Windows Firewall is enabled

    if (((Get-NetFirewallProfile | select name,enabled) | where { $_.Enabled -eq $True } | measure ).Count -eq 3) 
    {Write-Host "Firewall Enabled" -ForegroundColor Green} else {Write-Host "OFF" -ForegroundColor Red}

# Function - Verify Enforced SMB signing - Iterates through all 3 Firewall profiles and returns result
    Write-Host "Enforcing SMB Signing for Server and Workstation settings" -ForegroundColor Red -BackgroundColor Yellow
    Get-SmbServerConfiguration | Select EnableSecuritySignature, RequireSecuritySignature
    Get-SmbClientConfiguration | Select EnableSecuritySignature, RequireSecuritySignature
           
# Function - Verify if Symantec Endpoint Manager is installed
    Write-Host "Verifying if Symantec is installed" -ForegroundColor Red -BackgroundColor Yellow
    ((gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match "Symantec").Length -gt 0

# Function - Verify LLMNR and Netbios over TCP/IP
   Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient' -Name "EnableMulticast"
   Get-WmiObject win32_networkadapterconfiguration -filter 'IPEnabled=true' | select Description, TcpipNetbiosOptions

# Function - Verify Disablement of Downloaded maps manager, Geolocation services
# This needs some cleanup  
        Write-Host "Disabling Maps and Geolocation services" -ForegroundColor Red -BackgroundColor Yellow
        Get-Service -Name "MapsBroker"
        $featurenames = "lfsvc"

            $PassResult=""
            $FailResult=""

            foreach ($feature in $featurenames) {
              $check = Get-WindowsFeature -Name $feature 
             if ($check.Installed -ne "True") 
	        {
                $FailResult += "`n " + $check.Name + "   Description: " + $check.DisplayName 
	     }
            else
        {
                $PassResult += "`n " + $check.Name + "   Description: " + $check.DisplayName 
         }	
         }
          Write-Host "PASS : $PassResult `n`n FAIL : $FailResult"



# 2016 only Function - Disable SMB v1 - will likely error out on Windows 2019, but leaving for now
## Warn about scanners if selected in menu?
    Write-Host "Disabling SMBv1" -ForegroundColor Red -BackgroundColor Yellow
    Get-SMBServerConfiguration |Select EnableSMB1Protocol
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
 If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'SSL 2.0 Disabled'
        } Else {
            Write-Output 'SSL 2.0 Value DOES NOT exist'
            }

# Disable SSL 3.0
 If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'SSL 3.0 Disabled'
        } Else {
            Write-Output 'SSL 3.0 Value DOES NOT exist'
}
    
# Secure access to Config directory (SAM Database compromise mitigation    
    icacls C:\Windows\system32\config\*.* /inheritance:e 
  
# Disable weak ciphers and enable strong ciphers
    # Disable weak cyphers
     If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Null' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'Null Ciphers Disabled'
        } Else {
            Write-Output 'Null Ciphers Value DOES NOT exist'
}

    If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56\56' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'DES 56 Ciphers Disabled'
        } Else {
            Write-Output 'DEL 56 Ciphers Value DOES NOT exist'
}

    If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'RC2 40/128 Ciphers Disabled'
        } Else {
            Write-Output 'RC2 40/128 Ciphers Value DOES NOT exist'
}

   If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'RC2 128/128 Ciphers Disabled'
        } Else {
            Write-Output 'RC2 128/128 Ciphers Value DOES NOT exist'
}

  If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'RC4 40/128 Ciphers Disabled'
        } Else {
            Write-Output 'RC4 40/128 Ciphers Value DOES NOT exist'
}

  If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'RC4 56/128 Ciphers Disabled'
        } Else {
            Write-Output 'RC4 56/128 Ciphers Value DOES NOT exist'
}   

 If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'RC4 64/128 Ciphers Disabled'
        } Else {
            Write-Output 'RC4 64/128 Ciphers Value DOES NOT exist'
}
    
    # Enable strong cyphers
     If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'RC4 128/128 Strong Ciphers Enabled'
        } Else {
            Write-Output 'RC4 128/128 Strong Ciphers Enabled Value DOES NOT exist'
}
     If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'Triple DES 168/168 Strong Ciphers Enabled'
        } Else {
            Write-Output 'Triple DES 168/168 Strong Ciphers Enabled Value DOES NOT exist'
}

    If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'AES 128/128 Strong Ciphers Enabled'
        } Else {
            Write-Output 'AES 128/128 Strong Ciphers Enabled Value DOES NOT exist'
}
 
    If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'AES 128/128 Strong Ciphers Enabled'
        } Else {
            Write-Output 'AES 128/128 Strong Ciphers Enabled Value DOES NOT exist'
}
 
    If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256' -Name Enabled -ErrorAction SilentlyContinue) {
        Write-Output 'AES 256/256 Strong Ciphers Enabled'
        } Else {
            Write-Output 'AES 256/256 Strong Ciphers Enabled Value DOES NOT exist'
}

#Validate that Symantec has been installed.
Get-WmiObject -Class Win32_Product | sort-object Name | select Name | where { $_.Name -match “Symantec Endpoint Protection”}