function disable_updates {

    $WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
    $AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

    If(Test-Path -Path $WindowsUpdatePath) {
        Remove-Item -Path $WindowsUpdatePath -Recurse
    }

    New-Item $WindowsUpdatePath -Force
    New-Item $AutoUpdatePath -Force

    Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1

    # Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" | Disable-ScheduledTask
    # for PS without the scheduler module:
    $update_tasks = schtasks /query /tn "\Microsoft\Windows\WindowsUpdate\" /fo csv
    foreach ($line in $update_tasks[1..$update_tasks.Length]) {
        schtasks /delete /tn $line.Split(',')[0].Trim('"') /f
    }


    takeown /F C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /A /R
    icacls C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /grant Administrators:F /T

    # Get-ScheduledTask -TaskPath "\Microsoft\Windows\UpdateOrchestrator\" | Disable-ScheduledTask
    # again:
    $update_tasks = schtasks /query /tn "\Microsoft\Windows\UpdateOrchestrator\" /fo csv
    foreach ($line in $update_tasks[1..$update_tasks.Length]) {
        schtasks /delete /tn $line.Split(',')[0].Trim('"') /f
    }

    Stop-Service wuauserv
    Set-Service wuauserv -StartupType Disabled
}

function are_updates_enabled {
    (New-Object -ComObject "Microsoft.Update.AutoUpdate").ServiceEnabled
}
