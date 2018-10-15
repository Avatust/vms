function join_domain {
    param (
	[Parameter(Mandatory=$true)] [string]$domain
    )

   Add-Computer -DomainName $domain -Restart -Force
}
