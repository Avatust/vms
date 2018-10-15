function add_user {
    param(
	[Parameter(Mandatory=$true)] [string]$domain,
	[Parameter(Mandatory=$true)] [string]$name,
	[Parameter(Mandatory=$true)] [string]$password
    )

    $secure_pass = ConvertTo-SecureString -AsPlainText -Force -String $password

    New-ADUser
	-AccountPassword $secure_pass `
	-Enabled $true `
	-GivenName $name `
	-Name $name `
	-SamAccountName $name `
	-UserPrincipalName "$name@$domain"
}
