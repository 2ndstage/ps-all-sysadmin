 # Define results file
 $results = "<OUTPUT PATH>\Results.csv"

 # Define PolicyDefinition ADML Folder
 $policyDefs = "\\<FULLY_QUALIFIED_DOMAIN_NAME>\SYSVOL\<FULLY_QUALIFIED_DOMAIN_NAME>\Policies\PolicyDefinitions\en-US"
 
 # Generate a GPO report and capture it as XML
 [xml]$GPOs = Get-GPOReport -All -ReportType Xml
 
 # Parse captured XML
 $policyInfo = @()
 
 for ($i = 0; $i -lt ($GPOs.DocumentElement.GPO.Count); $i++)
 { 
     #Process Computer Policy
     for ($j = 0; $j -lt $GPOs.DocumentElement.GPO[$i].Computer.ExtensionData.ChildNodes.Count; $j++)
     { 
         if (($GPOs.DocumentElement.GPO[$i].Computer.ExtensionData.ChildNodes[$j].type) -like "*:RegistrySettings")
         {
             if (!($GPOs.DocumentElement.GPO[$i].Computer.ExtensionData.ChildNodes[$j].Policy.Count -eq $null))
             {
                 for ($k = 0; $k -lt $GPOs.DocumentElement.GPO[$i].Computer.ExtensionData.ChildNodes[$j].Policy.Count; $k++)
                 { 
                     $polInfo = "" | Select-Object gpoName, settingScope, settingName
                     $polInfo.gpoName = $GPOs.DocumentElement.GPO[$i].Name
                     $polInfo.settingScope = "Computer"
                     $polInfo.settingName = $GPOs.DocumentElement.GPO[$i].Computer.ExtensionData.ChildNodes[$j].Policy[$k].Name
                     $policyInfo += $polInfo
                 }
             }
             else
             {
                 $polInfo = "" | Select-Object gpoName, settingScope, settingName
                 $polInfo.gpoName = $GPOs.DocumentElement.GPO[$i].Name
                 $polInfo.settingScope = "Computer"
                 $polInfo.settingName = $GPOs.DocumentElement.GPO[$i].Computer.ExtensionData.ChildNodes[$j].Policy.Name
                 $policyInfo += $polInfo
             }
         }
     }
     #Process User Policy
     for ($j = 0; $j -lt $GPOs.DocumentElement.GPO[$i].User.ExtensionData.ChildNodes.Count; $j++)
     { 
         if (($GPOs.DocumentElement.GPO[$i].User.ExtensionData.ChildNodes[$j].type) -like "*:RegistrySettings")
         {
             if (!($GPOs.DocumentElement.GPO[$i].User.ExtensionData.ChildNodes[$j].Policy.Count -eq $null))
             {
                 for ($k = 0; $k -lt $GPOs.DocumentElement.GPO[$i].User.ExtensionData.ChildNodes[$j].Policy.Count; $k++)
                 { 
                     $polInfo = "" | Select-Object gpoName, settingScope, settingName
                     $polInfo.gpoName = $GPOs.DocumentElement.GPO[$i].Name
                     $polInfo.settingScope = "User"
                     $polInfo.settingName = $GPOs.DocumentElement.GPO[$i].User.ExtensionData.ChildNodes[$j].Policy[$k].Name
                     $policyInfo += $polInfo
                 }
             }
             else
             {
                 $polInfo = "" | Select-Object gpoName, settingScope, settingName
                 $polInfo.gpoName = $GPOs.DocumentElement.GPO[$i].Name
                 $polInfo.settingScope = "User"
                 $polInfo.settingName = $GPOs.DocumentElement.GPO[$i].User.ExtensionData.ChildNodes[$j].Policy.Name
                 $policyInfo += $polInfo
             }
         }
     }
 }
 
 # Define output array
 $admlFileUsage = @()
 
 # Search ADML files for policy settings
 $admlFiles = Get-ChildItem -Path $policyDefs -Filter *.adml
 
 foreach ($admlFile in $admlFiles)
 {
     $admlContent = (Get-Content -Path ($admlFile.FullName))
     $out = "" | Select-Object gpoName, settingScope, settingName, admlFile
     foreach ($polInfo in $policyInfo)
     {
         $settingName = $polInfo.settingName
         if ($admlContent -like "*$settingName*")
         {
             $out.gpoName = $polInfo.gpoName
             $out.settingScope = $polInfo.settingScope
             $out.settingName = $polInfo.settingName
             $out.admlFile = $admlFile.Name
             $admlFileUsage += $out
         }
     }
 }
 
 $admlFileUsage | Export-Csv -Path $results -NoTypeInformation -Force