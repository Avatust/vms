function create_ad {
    param (
        [Parameter(Mandatory=$true)] [string]$domain,
        [Parameter(Mandatory=$true)] [string]$password
    )

    $encrypted_password=ConvertTo-SecureString $password -AsPlainText -Force
    $domain_split = $domain.ToUpper().Split('.')
    $netbios = $domain_split[0..($domain_split.Length-2)] -join '_'

    Add-WindowsFeature -name ad-domain-services -IncludeManagementTools

    Import-Module ADDSDEployment

    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "Win2008R2" `
        -DomainName $domain `
        -DomainNetbiosName $netbios `
        -ForestMode "Win2008R2" `
        -InstallDns:$true `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$false `
        -SafeModeAdministratorPassword $encrypted_password `
        -SysvolPath "C:\Windows\SYSVOL" `
        -Force:$true
}
