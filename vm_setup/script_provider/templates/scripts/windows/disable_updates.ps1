function disable_updates {

    function delete_schtasks_folder {
        param([string]$tn)

        # on PS with a scheduler module it would be:
        # Get-ScheduledTask -TaskPath $tn | Disable-ScheduledTask

        $tasks = schtasks /query /tn $tn /fo csv
        foreach ($line in $tasks[1..$tasks.Length]) { # skip csv header
            try {
                # might try to remove the same task more times sometimes
                schtasks /delete /tn $line.Split(',')[0].Trim('"') /f
            } catch {
                # pass silently
            }
        }
    }

    $WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
    $AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

    If(Test-Path -Path $WindowsUpdatePath) {
        Remove-Item -Path $WindowsUpdatePath -Recurse
    }

    New-Item $WindowsUpdatePath -Force | Out-Null
    New-Item $AutoUpdatePath -Force | Out-Null

    Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1 | Out-Null

    delete_schtasks_folder -tn "\Microsoft\Windows\WindowsUpdate\"

    try {
        takeown /F C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /A /R
        icacls C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /grant Administrators:F /T
    }
    catch {
        log 'Update Orchestrator error'
    }

    delete_schtasks_folder -tn "\Microsoft\Windows\UpdateOrchestrator\"

    Stop-Service wuauserv
    Set-Service wuauserv -StartupType Disabled
}

function are_updates_enabled {
    (New-Object -ComObject "Microsoft.Update.AutoUpdate").ServiceEnabled
}
