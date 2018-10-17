function install_ms_office {
    param (
        [string]$office_url
    )

    $curdir = (pwd).ToString()
    $office_zip = "$curdir\Office2016.zip"
    $dest_dir = "$curdir\Office2016"

    # DOWNLOAD
    (New-Object System.Net.WebClient).DownloadFile($office_url, $office_zip)

    # EXTRACT
    mkdir $dest_dir | Out-Null
    $shell_app = New-Object -Com Shell.Application
    $zip_ns = $shell_app.NameSpace($office_zip)
    $dest_ns = $shell_app.NameSpace($dest_dir)
    $dest_ns.Copyhere($zip_ns.Items())

    # INSTALL & ACTIVATE
    cd Office2016
    .\install.bat
    .\activate.bat
    cd ..

    # CLEAN-UP
    Remove-Item -Recurse -Force $dest_dir
    Remove-Item -Force $office_zip
}
