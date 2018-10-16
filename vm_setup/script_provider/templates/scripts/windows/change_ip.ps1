function change_ip {
    param (
        [Parameter(Mandatory=$true)] [string]$ip,
        [Parameter(Mandatory=$true)] [string]$subnet,
        [string[]]$gateway,
        [string[]]$dns
    )

    $net_adapter = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"

    if (-Not ($net_adapter -is [System.Management.ManagementBaseObject])) {
        echo "Wrong type of network adapter, perhaps there are more interfaces, exiting"
        exit 1
    }

    $net_adapter.EnableStatic($ip, $subnet)
    #Sleep -Seconds 5

    if ($gateway -ne $null) {
        $net_adapter.SetGateways($gateway)
    }

    if ($dns -ne $null) {
        $net_adapter.SetDNSServerSearchOrder($dns)
    }
}
