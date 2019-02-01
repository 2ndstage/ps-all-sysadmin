$path=Split-Path $MyInvocation.MyCommand.path
#$cred= get-credential
$Computers = get-content "$path\computers.txt"  
foreach ($Computer in $Computers) 
{ 

$Disks = Get-wmiobject  Win32_LogicalDisk -computername $Computer -ErrorAction SilentlyContinue -filter "DriveType= 3" #-Credential $cred
$Servername = (Get-wmiobject  CIM_ComputerSystem -ComputerName $computer).Name
foreach ($objdisk in $Disks) 
{ 
    	$out=New-Object PSObject
	$total=“{0:N0}” -f ($objDisk.Size/1GB) 
	$free=($objDisk.FreeSpace/1GB) 
	$freePercent=“{0:P0}” -f ([double]$objDisk.FreeSpace/[double]$objDisk.Size) 
    	$out | Add-Member -MemberType NoteProperty -Name "Servername" -Value $Servername
    	$out | Add-Member -MemberType NoteProperty -Name "Drive" -Value $objDisk.DeviceID 
    	$out | Add-Member -MemberType NoteProperty -Name "Total size (GB)" -Value $total
    	$out | Add-Member -MemberType NoteProperty -Name “Free Space (GB)” -Value $free
    	$out | Add-Member -MemberType NoteProperty -Name “Free Space (%)” -Value $freePercent
    	$out | Add-Member -MemberType NoteProperty -Name "Name " -Value $objdisk.volumename
    	$out | Add-Member -MemberType NoteProperty -Name "DriveType" -Value $objdisk.DriveType
	$out | export-csv $path\Diskspace_Report.csv -NoTypeInformation -Append  
}

}

