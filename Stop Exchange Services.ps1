﻿# Stop MSExchangeADTopology Dependent servicesforeach ($svc in get-service MSExchangeADTopology) {$dep = $svc.dependentservices}foreach ($aa in $dep){get-service $aa.Name | select Name,statusstop-service $aa.Nameget-service $aa.Name | select Name,status} # Stop all services with the name Exchange$svcstatus = get-service *exchange* | select name,statusforeach ($mystatus in $svcstatus -eq "Running") {$mystatus = $svcstatus.Status}foreach ($ab in $svcstatus){get-service $ab.Name | select Name,statusstop-service $ab.Name -fget-service $ab.Name | select Name,status}