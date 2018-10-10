$HOST_NUM = ''
$DNS_SERVER = ''

$interface = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"

if (-Not ($interface -is [System.Management.ManagementBaseObject])) {
   echo "Wrong type, perhaps there are more interfaces, exiting"
   exit 1
}

$interface.EnableStatic("10.114.48.$HOST_NUM", "255.255.255.0")
Sleep -Seconds 5
$interface.SetGateways("10.114.48.1", 1)
$interface.SetDNSServerSearchOrder("$DNS_SERVER")