$ErrorActionPreference = 'Inquire'

{% include "scripts/windows/add_user.ps1" %}
{% include "scripts/windows/change_ip.ps1" %}
{% include "scripts/windows/create_ad.ps1" %}
{% include "scripts/windows/disable_updates.ps1" %}
{% include "scripts/windows/forward_dns.ps1" %}
{% include "scripts/windows/install_ms_office.ps1" %}
{% include "scripts/windows/join_domain.ps1" %}


$ADD_USER = 'ADD_USER'
$CHANGE_IP = 'CHANGE_IP'
$CREATE_AD = 'CREATE_AD'
$DISABLE_UPDATES = 'DISABLE_UPDATES'
$FORWARD_DNS = 'FORWARD_DNS'
$INSTALL_MS_OFFICE = 'INSTALL_MS_OFFICE'
$JOIN_DOMAIN = 'JOIN_DOMAIN'

$W7 = 'windows7'
$W10 = 'windows10'
$WS = 'wserver'

### CONTROL VARS ###
$logging_url = "{{ logging_url }}"
$set_number = {{ set_number }}
$domain_base = "Set_$set_number"
$domain = "$domain_base.ad"
$office_url = '{{ office_url|default:"none" }}'
$machine = '{{ machine }}'
$dns = "10.114.48.$(5*$set_number - 2)"
switch ($machine) {
    $WS  {
        $ip = "10.114.48.$(5*$set_number - 2)"
        $dns = '193.167.197.100'
    }
    $W7  { $ip = "10.114.48.$(5*$set_number - 1)" }
    $W10 { $ip = "10.114.48.$(5*$set_number)" }
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
$dict.Add('set_number', $set_number)
$dict.Add('message', 'log setup')

function log {
    param ($message)
    echo $message
    echo $message >> $log_path
    $dict['message'] = $message
    $response = $web_client.UploadValues($logging_url, 'POST', $dict)
}
log "(re)start at $((Get-Date).ToString())"
$log = Get-Content -Path $log_path

# schedule
$command = "PowerShell -ExecutionPolicy ByPass -File '$this_script'"
SCHTASKS /Create /TN 'course_config' /TR $command /RU System /SC ONSTART /F

# network settings (all machines)
if ($log -notcontains $CHANGE_IP) {
    log $CHANGE_IP
    change_ip -ip $ip -subnet '255.255.255.0' -gateway '10.114.48.1' -dns $dns
    Sleep -Seconds 5
}

if ($machine -eq $WS) {
    if ($log -notcontains $CREATE_AD) {
        log $CREATE_AD
        create_ad -domain $domain -password 'Test!!test'
        Sleep -Seconds 1
        shutdown /r /t 10
        pause
    }

    if ($log -notcontains $FORWARD_DNS) {
        log $FORWARD_DNS
        forward_dns
        Sleep -Seconds 1
    }

    if ($log -notcontains $ADD_USER) {
        log $ADD_USER
        add_user -domain $domain -name 'test7' -password 'User!!user'
        add_user -domain $domain -name 'test10' -password 'User!!user'
        Sleep -Seconds 1
    }

} elseif ($log -notcontains $JOIN_DOMAIN) {
        log $JOIN_DOMAIN
        join_domain -domain $domain -username '$domain_base\Administrator' -password 'Opetus2016'
        Sleep -Seconds 1
}

if (are_updates_enabled) {
    log 'UPDATES ENABLED'
    disable_updates
    Sleep -Seconds 1
    shutdown /r /t 10
    pause
} else {
    log 'updates are disabled'
}

if ( ($machine -eq $W10) -And ($log -notcontains $INSTALL_MS_OFFICE) ) {
    log $INSTALL_MS_OFFICE
    install_ms_office -office_url $office_url
    Sleep -Seconds 1
}

if ($log -notcontains 'restarting') {
    log 'restarting'
    shutdown /r /t 60
    pause
} else {
    # unschedule and clean
    Remove-Item -Path "$this_script" -Force

    log 'done'
    Remove-Item -Path "$log_path" -Force #sometimes not deleted
    SCHTASKS /Delete /TN 'course_config' /F
}

