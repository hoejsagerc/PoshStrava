function Get-StravaAthleteId {
    <#
    .SYNOPSIS
        Helper function for returning the Authenticated Athletes Id
    .DESCRIPTION
        This helper function is primarely used for supporting the cmdlet Get-StravaAtheteStats which required the user to enter the authenticated athletes id
    .EXAMPLE
        Get-StravaAthleteId
        
        This example will return the authenticated athletes id. If the athletes id could not be found, then the function will return $false
    .PARAMETER AccessToken
        Access token to authenticate with the Strava API. If you used the parameter switch -UseSecretStore when you run 
        the cmdlet Set-StravaAuthentication. The access token is stored in the PowerShell secret store, and should not 
        be provided to this cmdlet.
    #>
    [CmdletBinding()]
    param (
        # Access Token for authenticating the Strava API
        [Parameter(Mandatory=$false)]
        [String]$AccessToken
    )
    
    begin {
        $resource = "athlete"
    }
    
    process {
        if ($AccessToken) {
            $data = Invoke-StravaApi -Method "GET" -Resource $resource -AccessToken $AccessToken
        }
        else {
            $data = Invoke-StravaApi -Method "GET" -Resource $resource
        }
    }
    
    end {
        $athleteId = $data | Select-Object -ExpandProperty id
        if ($athleteId) {
            return $athleteId
        }
        else {
            return $false
        }
    }
}