$domain=''
$netbios=''
$password=''

$password=ConvertTo-SecureString $password -AsPlainText -Force

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
-SafeModeAdministratorPassword $password `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true