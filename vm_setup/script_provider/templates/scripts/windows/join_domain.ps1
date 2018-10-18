function join_domain {
    param (
        [Parameter(Mandatory=$true)] [string]$domain,
        [string]$username,
        [string]$password
    )

    if ($username -And $password) {
        $encrypted_password = ConvertTo-SecureString $password -AsPlainText -Force
        $pscreds = New-Object System.Management.Automation.PSCredential ($username, $encrypted_password)

        Add-Computer -DomainName $domain -Credential $pscreds
    } else {
        Add-Computer -DomainName $domain
    }
}
