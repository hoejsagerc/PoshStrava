function Get-StravaSecrets {
    <#
    .SYNOPSIS
        Small helper function for retrieving strava secrets
    .DESCRIPTION
        A small helper function which connects to the PowerShell Secret Store and pulls the refresh_token, client_id and $client_secret
        stored in the StravaSecrets Vault. This function requires that the user has run Set-StravaAuthentication function before.

        The function will set the three secrets into script variables. This allows them to be used in the rest of the module.
    .EXAMPLE
        Get-StravaSecrets
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    .PARAMETER VaultName
        Variable used for storing the name of the Secret Vault. Can be changed if a custom vault is used.
    #>

    [CmdletBinding()]
    param (
        # Parameter for setting the Secret Vault
        [Parameter(Mandatory=$false)]
        [String]$VaultName = "StravaSecrets"   
    )

<#     try {
        $refresh_token = Get-Secret -Name refresh_token -Vault $VaultName -AsPlainText
        Write-Verbose -Message "Setting the script variable STRAVA_REFRESH_TOKEN"
        Set-Variable -Name STRAVA_REFRESH_TOKEN -Value $refresh_token -Scope Script
    }
    catch {
        Write-Error -Message $($_)
    }


    try {
        $client_id = Get-Secret -Name client_id -Vault $VaultName -AsPlainText
        Write-Verbose -Message "Setting the script variable STRAVA_CLIENT_ID"
        Set-Variable -Name STRAVA_CLIENT_ID -Value $client_id -Scope Script
    }
    catch {
        Write-Error -Message $($_)
    }


    try {
        $client_secret = Get-Secret -Name client_secret -Vault $VaultName -AsPlainText
        Write-Verbose -Message "Setting the script variable STRAVA_CLIENT_SECRET"
        Set-Variable -Name STRAVA_CLIENT_SECRET -Value $client_secret -Scope Script
    }
    catch {
        Write-Error -Message $($_)
    } #>

    try {
        $access_token = Get-Secret -Name access_token -Vault $VaultName -AsPlainText
        Write-Verbose -Message "Setting the script variable STRAVA_CLIENT_SECRET"
        Set-Variable -Name STRAVA_ACCESS_TOKEN -Value $access_token -Scope Script
        return $true
    }
    catch {
        return $false
    }
}