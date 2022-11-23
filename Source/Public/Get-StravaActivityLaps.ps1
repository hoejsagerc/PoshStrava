function Get-StravaActivityLaps {
    <#
    .SYNOPSIS
        Cmdlet for retrieving all Laps from an activity
    .DESCRIPTION
        This cmdlet will return all the laps from a Strava Activity.
        The cmdlet can output the result to a json file

        This cmdlet required you to have a strava subscription to be able to query the data
    .EXAMPLE
        Get-StravaActivityLaps -Id 7551294509
        
        This example will output an object containing all the laps created on the spicific activity with the Id 7551294509
    .EXAMPLE
        Get-StravaActivityLaps -Id 7557894309 -OutputJson -Path ~/temp/strava_output.json

        This example will output all the laps from an activity to a json file and create the file in the path
        ~/temp/strava_output.json
    .PARAMETER Id
        The Activity Id of a specific Strava Activity
    .PARAMETER OutputJson
        Switch parameter to define if the output from the command should be saved to a json file
    .PARAMETER Path
        If you defined the switch OutputJson, you can define a path to where the file should be stored.
        If no path is defined, the file will be saved in your current directory as ./strava_output.json
    .PARAMETER Page
        You can define the Page number for the pagination when querying the Strava API by default it will start
        on page 1
    .PARAMETER PerPage
        You can define how many activities you want listed on each page queried from the Strava API
    .PARAMETER AccessToken
        Access token to authenticate with the Strava API. If you used the parameter switch -UseSecretStore when you run 
        the cmdlet Set-StravaAuthentication. The access token is stored in the PowerShell secret store, and should not 
        be provided to this cmdlet.
    #>
    [CmdletBinding()]
    param (
        # Parameter for providing an id to list a specific activity in detail
        [Parameter(Mandatory=$true, HelpMessage="Please enter the specific strave activity id")]
        [Long]$Id,
        # Parameter to define if the output should be saved in a json file
        [Parameter(Mandatory=$false, ParameterSetName="output")]
        [Switch]$OutputJson,
        # Parameter if the output should be saved in a json file, then the path to the file is needed
        [Parameter(Mandatory=$false, ParameterSetName="output")]
        [String]$Path = "./strava_output.json",
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [Int]$Page = 1,
        # Parameter help description
        [Parameter(Mandatory=$false)]
        [Int]$PerPage = 200,
        # Access Token for authenticating the Strava API
        [Parameter(Mandatory=$false)]
        [String]$AccessToken
    )
    
    begin {
        $resource = "activities/$($Id)/laps "
        Write-Verbose -Message "Id was provided: $($Id)"
        Write-Verbose -Message "Calling API endpoint: $($resource)"
    }
    
    process {
        $allData = New-Object System.Collections.ArrayList
        $pageContent = $true
        While ($pageContent) {
            if ($AccessToken) {
                $data = Invoke-StravaApi -Method "GET" -Resource $resource -AccessToken $AccessToken -Pagination -Page $Page -PerPage $PerPage -ErrorAction SilentlyContinue    
            }
            else {
                $data = Invoke-StravaApi -Method "GET" -Resource $resource -Pagination -Page $Page -PerPage $PerPage -ErrorAction SilentlyContinue
            }
            foreach($object in $data) {
                $allData.Add($object) | Out-Null
            }
            $pageContent = [bool]$data
    
            $Page++
        }
    }
    
    end {
        if ($allData.Count -gt 0) {
            if($OutputJson) {
                ($allData | ConvertTo-Json -Depth 4) | Out-File -FilePath $Path
                Write-Verbose -Message "Outputting json file to path: $($Path)"
                return "File generated: $($Path)"
            }
            return $allData
        }
        else {
            return "Failed fetching data from Strava"
        }
    }
}