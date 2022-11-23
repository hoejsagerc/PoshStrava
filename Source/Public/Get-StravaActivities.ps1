function Get-StravaActivities {
    <#
    .SYNOPSIS
        Cmdlet for retriving either a single Strava activity or all the Strava activies from your Strava account
    .DESCRIPTION
        This cmdlet can be used to retrieve a single Strava activity by the Activity Id, or you can 
        retrieve all the activites from your account.
    .EXAMPLE
        Get-StravaActivities -Verbose
        
        This example will retrieve all the activities from your Strava account, and provide Verbose information
    .EXAMPLE
        Get-StravaActivities -Id 1736127843 -IncludeAlEfforts

        This example will retrieve all details on the specific Strava activity with the Id 1736127843
    .EXAMPLE
        Get-StravaActivities -OutputJson -Path "~/temp/activities_output.json"

        This example will save a json file with all the strava activies. It will store the file in the path
        "~/temp/activities_output.json"
    .PARAMETER Id
        The Activity Id of a specific Strava Activity
    .PARAMETER IncludeAllEfforts
        Switch to define if you want to retrieve all the segment efforts you made on the specific Strava
        activity. This switch should be used combined with the Id parameter
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

    [CmdletBinding(DefaultParameterSetName="all")]
    param (
        # Parameter for providing an id to list a specific activity in detail
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ParameterSetName="single")]
        [Long]$Id,
        # Parameter switch to include all efforts from the activity
        [Parameter(Mandatory=$false, ParameterSetName="single")]
        [Switch]$IncludeAllEfforts,
        # Parameter to define if the output should be saved in a json file
        [Parameter(Mandatory=$false, ParameterSetName="output")]
        [Switch]$OutputJson,
        # Parameter if the output should be saved in a json file, then the path to the file is needed
        [Parameter(Mandatory=$false, ParameterSetName="output")]
        [String]$Path = "./strava_output.json",
        # Parameter help description
        [Parameter(Mandatory=$false, ParameterSetName="all")]
        [Int]$Page = 1,
        # Parameter help description
        [Parameter(Mandatory=$false, ParameterSetName="all")]
        [Int]$PerPage = 200,
        # Access Token for authenticating the Strava API
        [Parameter(Mandatory=$false)]
        [String]$AccessToken
    )
    
    begin {
        if ($Id) {
            $resource += "activities/$($Id)?include_all_efforts=$($IncludeAllEfforts)"
            Write-Verbose -Message "Id was provided: $($Id)"
        }
        else {
            $resource = "athlete/activities"
        }

        Write-Verbose -Message "Calling API endpoint: $($resource)"
    }
    
    process {

        if ($Id) {
            if ($AccessToken){
                $data = Invoke-StravaApi -Method "GET" -Resource $resource -AccessToken $AccessToken    
            }
            else {
                $data = Invoke-StravaApi -Method "GET" -Resource $resource
            }
            $allData = New-Object System.Collections.ArrayList 
            foreach($object in $data) {
                $newDataProperties = @{}
                foreach($key in $object.PSObject.Properties) {
                    Write-Verbose "Modifying Key: $($key.Name)"
                    $newKey = ($key.Name -split '_' | ForEach-Object {
                        "$($_.ToCharArray()[0].ToString().ToUpper())$($_.Substring(1))" }) -join ''
                    Write-Verbose "New name: $($newKey)"

                    $newDataProperties.Add("$($newKey)", "$($key.Value)")
                }
                $outputObject = New-Object -TypeName psobject -Property $newDataProperties
                $allData.Add($outputObject) | Out-Null
            }
        }
        else {
            $allData = New-Object System.Collections.ArrayList
            $pageContent = $true
            While ($pageContent) {
                if ($AccessToken){
                    $data = Invoke-StravaApi -Method "GET" -Resource $resource -AccessToken $AccessToken -Pagination -Page $Page -PerPage $PerPage -ErrorAction SilentlyContinue    
                }
                else {
                    $data = Invoke-StravaApi -Method "GET" -Resource $resource -Pagination -Page $Page -PerPage $PerPage -ErrorAction SilentlyContinue
                }
                foreach($object in $data) {
                    $newDataProperties = @{}
                    foreach($key in $object.PSObject.Properties) {
                        Write-Verbose "Modifying Key: $($key.Name)"
                        $newKey = ($key.Name -split '_' | ForEach-Object {
                            "$($_.ToCharArray()[0].ToString().ToUpper())$($_.Substring(1))" }) -join ''
                        Write-Verbose "New name: $($newKey)"

                        $newDataProperties.Add("$($newKey)", "$($key.Value)")
                    }
                    $outputObject = New-Object -TypeName psobject -Property $newDataProperties
                    $allData.Add($outputObject) | Out-Null
                }
                $pageContent = [bool]$data
                $Page++
            }
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