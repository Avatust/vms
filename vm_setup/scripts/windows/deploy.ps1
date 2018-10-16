{% include "./add_user.ps1" %}
{% include "./change_ip.ps1" %}
{% include "./create_ad.ps1" %}
{% include "./disable_updates.ps1" %}
{% include "./forward_dns.ps1" %}
{% include "./install_ms_office.ps1" %}
{% include "./join_domain.ps1" %}


$ADD_USER = 'ADD_USER'
$CHANGE_IP = 'CHANGE_IP'
$CREATE_AD = 'CREATE_AD'
$DEPLOY = 'DEPLOY'
$DISABLE_UPDATES = 'DISABLE_UPDATES'
$FORWARD_DNS = 'FORWARD_DNS'
$INSTALL_MS_OFFICE = 'INSTALL_MS_OFFICE'
$JOIN_DOMAIN = 'JOIN_DOMAIN'

$W7 = 'windows7'
$W10 = 'windows10'
$WS = 'wserver'

### CONTROL VARS ###
$server_address = "{{ server_address }}"
$set_no = {{ set_no }}
$domain = "Set_$set_no.ad"
$office_url = '{{ office_url|default:"none" }}'
$machine = '{{ machine }}'
$dns = "10.114.48.$(5*$set_no - 2)"
switch ($machine) {
    $WS  {
        $ip = "10.114.48.$(5*$set_no - 2)"
        $dns = '193.167.197.100'
    }
    $W7  { $ip = "10.114.48.$(5*$set_no - 1)" }
    $W10 { $ip = "10.114.48.$(5*$set_no)" }
    Default { echo 'bad machine'; pause}
}

### DEPLOYMENT ###
# scheduled task together with log will ensure execution in order even after restart

# paths and log
$this_script = $MyInvocation.MyCommand.Definition.ToString()
$log_path = 'C:\course_config.log'

$web_client = New-Object System.Net.WebClient
$dict = New-Object System.Collections.Specialized.NameValueCollection
$dict.Add('machine_os', $machine)
$dict.Add('set_number', $set_no)
$dict.Add('message', 'log setup')

function log {
    param ($message)
    echo $message >> $log_path
    $dict['message'] = $message
    $web_client.UploadValues($server_address, 'POST', $dict)
}
log "(re)start at $((Get-Date).ToString())"
$log = Get-Content -Path $log_path

# schedule
SCHTASKS /Create /TN 'course_config' /TR "PowerShell -File \"$this_script\"" /RU System /SC ONSTART /F

# network settings (all machines)
if ($log -notcontains $CHANGE_IP) {
    log $CHANGE_IP
    change_ip -ip $ip -subnet '255.255.255.0' -gateway '10.114.48.1' -dns $dns
}

if ($machine -eq $WS) {
    if ($log -notcontains $CREATE_AD) {
        log $CREATE_AD
        create_ad -domain $domain -password 'Test!!test'
    }

    if ($log -notcontains $FORWARD_DNS) {
        log $FORWARD_DNS
        forward_dns
    }

    if ($log -notcontains $ADD_USER) {
        log $FORWARD_DNS
        add_user -domain $domain -name 'test7' -password 'User!!user'
        add_user -domain $domain -name 'test10' -password 'User!!user'
    }

} elseif ($log -notcontains $JOIN_DOMAIN) {
        log $JOIN_DOMAIN
        join_domain -domain $domain
}

if (are_updates_enabled) {
    log 'UPDATES ENABLED'
    disable_updates
} else {
    log 'updates are disabled'
}

if ( ($machine -eq $W7) -And ($log -notcontains $INSTALL_MS_OFFICE) ) {
    log $INSTALL_MS_OFFICE
    install_ms_office -office_rul $office_url
}

# unschedule and clean
log 'done'
SCHTASKS /Delete /TN 'course_config' /F
Remove-Item -Path "$this_script" -Force
Remove-Item -Path "$log_path" -Force
