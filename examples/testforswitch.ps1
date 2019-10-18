$getVMNetworkAdapterResult = Get-VMNetworkAdapter -ManagementOS -SwitchName "External switch" | select deviceid
$getNetAdapterResult = Get-NetAdapter | select name, deviceid, ifindex, interfacedescription
$wmiResult = gwmi win32_networkadapterconfiguration -filter "IPEnabled = 'TRUE'"
