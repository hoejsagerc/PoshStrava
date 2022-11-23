function Get-StravaAthlete {
    <#
    .SYNOPSIS
        Cmdlet for retrieving profile information on the authenticated Athlete
    .DESCRIPTION
        This cmdlet will return the profile information on the current authenticated athlete
    .EXAMPLE
        Get-StravaAthlete
        
        This example will output an object containing the profile information for the authenticated athlete
    .PARAMETER OutputJson
        Switch parameter to define if the output from the command should be saved to a json file
    .PARAMETER Path
        If you defined the switch OutputJson, you can define a path to where the file should be stored.
        If no path is defined, the file will be saved in your current directory as ./strava_output.json
    .PARAMETER AccessToken
        Access token to authenticate with the Strava API. If you used the parameter switch -UseSecretStore when you run 
        the cmdlet Set-StravaAuthentication. The access token is stored in the PowerShell secret store, and should not 
        be provided to this cmdlet.
    #>
    [CmdletBinding()]
    param (
        # Parameter to define if the output should be saved in a json file
        [Parameter(Mandatory=$false, ParameterSetName="output")]
        [Switch]$OutputJson,
        # Parameter if the output should be saved in a json file, then the path to the file is needed
        [Parameter(Mandatory=$false, ParameterSetName="output")]
        [String]$Path = "./strava_output.json",
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
        return $data
    }
}