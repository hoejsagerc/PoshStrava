### --- PUBLIC FUNCTIONS --- ###
#Region - Get-StravaActivities.ps1
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
Export-ModuleMember -Function Get-StravaActivities
#EndRegion - Get-StravaActivities.ps1
#Region - Get-StravaActivityComments.ps1
function Get-StravaActivityComments {
    <#
    .SYNOPSIS
        Cmdlet for retrieving all comments on an activity
    .DESCRIPTION
        This cmdlet will return all the comments added to a Strava Activity.
        The cmdlet can output the result to a json file
    .EXAMPLE
        Get-StravaActivityComments -Id 7551294509
        
        This example will output an object containing all the comments created on the spicific activity with the Id 7551294509
    .EXAMPLE
        Get-StravaActivityComments -Id 7557894309 -OutputJson -Path ~/temp/strava_output.json

        This example will output all the comments from an activity to a json file and create the file in the path
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
        $resource = "activities/$($Id)/comments"
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
Export-ModuleMember -Function Get-StravaActivityComments
#EndRegion - Get-StravaActivityComments.ps1
#Region - Get-StravaActivityKudoers.ps1
function Get-StravaActivityKudoers {
    <#
    .SYNOPSIS
        Cmdlet for retrieving all comments on an activity
    .DESCRIPTION
        This cmdlet will return all the kudos added to a Strava Activity.
        The cmdlet can output the result to a json file
    .EXAMPLE
        Get-StravaActivityKudoers -Id 7551294509
        
        This example will output an object containing all the kudos created on the spicific activity with the Id 7551294509
    .EXAMPLE
        Get-StravaActivityKudoers -Id 7557894309 -OutputJson -Path ~/temp/strava_output.json

        This example will output all the kudos from an activity to a json file and create the file in the path
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
        $resource = "activities/$($Id)/kudos"
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
Export-ModuleMember -Function Get-StravaActivityKudoers
#EndRegion - Get-StravaActivityKudoers.ps1
#Region - Get-StravaActivityLaps.ps1
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
Export-ModuleMember -Function Get-StravaActivityLaps
#EndRegion - Get-StravaActivityLaps.ps1
#Region - Get-StravaActivityZones.ps1
function Get-StravaActivityZones {
    <#
    .SYNOPSIS
        Cmdlet for retrieving all Zones from an activity
    .DESCRIPTION
        This cmdlet will return all the zones from a Strava Activity.
        The cmdlet can output the result to a json file

        This cmdlet required you to have a strava subscription to be able to query the data
    .EXAMPLE
        Get-StravaActivityZones -Id 7551294509
        
        This example will output an object containing all the zones created on the spicific activity with the Id 7551294509
    .EXAMPLE
        Get-StravaActivityZones -Id 7557894309 -OutputJson -Path ~/temp/strava_output.json

        This example will output all the Zones from an activity to a json file and create the file in the path
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
        $resource = "activities/$($Id)/zones "
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
Export-ModuleMember -Function Get-StravaActivityZones
#EndRegion - Get-StravaActivityZones.ps1
#Region - Get-StravaAthlete.ps1
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
Export-ModuleMember -Function Get-StravaAthlete
#EndRegion - Get-StravaAthlete.ps1
#Region - Get-StravaAthleteStats.ps1
function Get-StravaAthleteStats {
    <#
    .SYNOPSIS
        Cmdlet for retrieving the authenticated athletes stats
    .DESCRIPTION
        This cmdlet will query the api to first find the currently authenticated atheletes id, and return the athletes stats
    .EXAMPLE
        Get-StravaAthleteStats
        
        This example will output an object containing the athletes stats
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
        if ($AccessToken) {
            $athleteId = Get-StravaAthleteId -AccessToken $AccessToken
        }
        else {
            $athleteId = Get-StravaAthleteId
        }
        
        if ($athleteId -ne $false) {
            $resource = "athletes/$($athleteId)/stats"
            Write-Verbose -Message "Athelete Id found: $($athleteId)"
        }
        else {
            Write-Error -Message "Failed retriving the athletes Id."
        }
        
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
Export-ModuleMember -Function Get-StravaAthleteStats
#EndRegion - Get-StravaAthleteStats.ps1
#Region - Get-StravaAthleteZones.ps1
function Get-StravaAthleteZones {
    <#
    .SYNOPSIS
        Cmdlet for retrieving Zones information on the currently authenticated athlete
    .DESCRIPTION
        This cmdlet will return the heart rate and power zones of the currently authenticated athlete
    .EXAMPLE
        Get-StravaAthleteZones
        
        This example will output an object containing heart rate and power zones of the currently authenticated athelete
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
        $resource = "athlete/zones"
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
Export-ModuleMember -Function Get-StravaAthleteZones
#EndRegion - Get-StravaAthleteZones.ps1
#Region - New-StravaActivity.ps1
function New-StravaActivity {
    [CmdletBinding()]
    param (
        # The name of the activity
        [Parameter(Mandatory=$true, HelpMessage="Name of the activity you want to create")]
        [String]$Name,
        # Sport type of activity. For example - Run, MountainBikeRide, Ride, etc.
        [Parameter(Mandatory=$true, HelpMessage="Sport type of activity. For example - Run, MountainBikeRide, Ride, etc.")]
        [ValidateSet("Run", "Trail Run", "Walk", "Hike", 
            "Virtual Run", "Ride", "Mountain Bike Ride", "Gravel Bike Ride", "E-Bike Ride", "E-Mountain Bike Ride", "Velomobile", "Virtual Ride",
            "Canoe", "Kayak", "Kitesurf Session", "Row", "Stand Up Paddle", "Surf", "Swim", "Windsurf Session",
            "Ice Skate", "Alpine Ski", "Backcountry Ski", "Nordic Ski", "Snowboard", "Snowshoe",
            "Handcycle", "Inline Skate", "Rock Climb", "Roller Ski", "Wheelchair", "Crossfit", "Elliptical", "Stair Stepper", "Weight Training", "Weight Training", "Workout")]
        [String]$SportType,
        # ISO 8601 formatted date time
        [Parameter(Mandatory=$true, HelpMessage="Must be in ISO 8601 Standard => '2022-08-10T11:55:10.9626456+02:00' - You can use {Get-Date -Format 'o'}")]
        [Datetime]$StartDate,
        # Activity elapsed time in seconds
        [Parameter(Mandatory=$true, HelpMessage="Elapsed time should be in seconds")]
        [String]$ElapsedTime,
        # Type of activity. For example - Run, Ride etc.
        [Parameter(Mandatory=$false)]
        [String]$Type = $false,
        # Description of the activity
        [Parameter(Mandatory=$false)]
        [String]$Description = $false,
        # Activity distance n meters
        [Parameter(Mandatory=$false)]
        [Float]$Distance = $false,
        # Set to mark as a trainer activity
        [Parameter(Mandatory=$false)]
        [Switch]$Trainer,
        # Set to mark as commute
        [Parameter(Mandatory=$false)]
        [Switch]$Commute,
        # Set to mute activity
        [Parameter(Mandatory=$false)]
        [Switch]$HideFromHome,
        # Access Token for authenticating the Strava API
        [Parameter(Mandatory=$false)]
        [String]$AccessToken
    )
    
    begin {
        $resource = "activities"
        $method = "POST"

        if ($Trainer.IsPresent) {
            Write-Verbose -Message "Activity is set as a Trainer activity"
            $trainerActivity = 1
        }
        else {
            Write-Verbose -Message "Activity is not set as a Trainer activity"
            $trainerActivity = $false
        }
        
        if ($Commute.IsPresent) {
            Write-Verbose -Message "Activity is set as a Commute"
            $commuteActivity = 1
        }
        else {
            Write-Verbose -Message "Activity is not set as a Commute"
            $commuteActivity = $false
        }

        if ($HideFromHome.IsPresent) {
            Write-Verbose -Message "Activity is set as muted"
            $HideFromHome = $true
        }
        else {
            Write-Verbose -Message "Activity is set as active"
            $HideFromHome = $false
        }

    }
    
    process {
        $payload = @{
            "name"                = $Name;
            "type"                = $Type;
            "sport_type"          = $SportType;
            "start_date_local"    = $StartDate;
            "elapsed_time"        = $ElapsedTime;
            "description"         = $Description;
            "distance"            = $Distance;
            "trainer"             = $trainerActivity;
            "commute"             = $commuteActivity;
            "hide_from_home"      = $HideFromHome;
        }

        Write-Verbose -Message "Building Payload"
        $keysToRemove = New-Object System.Collections.ArrayList
        foreach($key in $payload.GetEnumerator()) {
            if ($null -eq $key.Value) {
                $keysToRemove.Add($key.Name) | Out-Null
                Write-Verbose -Message "Removing key: $($key.Name) from payload since value = $($key.Value)"
            }
        }
        foreach($name in $keysToRemove) {
            $payload.Remove($name)
        }

        if ($AccessToken) {
            $data = Invoke-StravaApi -Method $method -Resource $resource -AccessToken $AccessToken -Payload $payload
        }
        else {
            $data = Invoke-StravaApi -Method $method -Resource $resource -Payload $payload
        }
    }
    
    end {
        return $data
    }
}
Export-ModuleMember -Function New-StravaActivity
#EndRegion - New-StravaActivity.ps1
#Region - Set-StravaAuthentication.ps1
function Set-StravaAuthentication {
    <#
    .SYNOPSIS
        Function for setting up your strava authentication for the first time.
    .DESCRIPTION
        This function requires that you have alreaded create the API application in your Strava Account.

        if you haven't already created a Strava API App you will need to go to url: https://www.strava.com/settings/api
        Once you have created the API App you should be able to find your API setting under: Strava profile -->
        Settings --> My API Application

        Under the panel 'My API Application' you will be able to find: Client ID and Client Secret. These two values you will
        need to use for this function.

        When you run the function, a web browser will be opened. Here you will be prompted to Authenticate your application.
        Once you've pressed the Authenticate button you will be redirected to a localhost page. On this page you will need to 
        take the 'code' parameter in the URL.

        It will look similar to: code=32e0113c8a5f7b704570349619c24fa567770e27    <-- You should not take the 'code=' part of the url.
        Only copy the code.

        From this code you will generate a new refresh_token which will be used for every api call to authenticate to the API.

        To save the client_id, client_secret & refresh_token, the function will install a new Secrets Vault named StravaSecrets.
        If you already have a vault canfigured it will use the password for this vaul, otherwise you will be prompted to create a 
        new password. This password you will need to use everytime you run a strava command in a new PowerShell session.

        This function should only be run the first time you want to use the PowerShell Module
    .LINK
        https://github.com/ScriptingChris/PoshStrava/blob/main/README.md
    .EXAMPLE
        Set-StravaAuthentication -ClientId "8121231" -ClientSecret "kl2n1lkn66kln31lk1243kn41n423114lknasdp9"
        
        This example will Authenticate you to Strava and store the authentication tokens and secret in a PowerShell Secrets Vault. 
    .PARAMETER ClientId
        The Client Id found on your Strava Account. Go to Settings --> My API Application --> Client ID
    .PARAMETER ClientSecret
        The Client Secret found on your Strava Account. Go to Settings --> My API Application --> Client Secret
    .PARAMETER ScopeReadAll
        Set the authentication scope to activity:read_all
    .PARAMETER ScopeWriteActivity
        Set the authentication scope to activity:write
    .PARAMETER ScopeWriteProfile
        Set the authentication scope to profile:write
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, HelpMessage="You can find the client_id on your strava account")]
        [String]$ClientId,
        [Parameter(Mandatory=$false, HelpMessage="You can find the client_secret on your strava account")]
        [String]$ClientSecret,
        [Parameter(Mandatory=$false)]
        [Switch]$UseSecretStore
    )
    
    $msg = 
@"
     ________  ___________  _______        __  ___      ___  __          
    /"       )("     _   ")/"      \      /""\|"  \    /"  |/""\         
   (:   \___/  )__/  \\__/|:        |    /    \\   \  //  //    \        
    \___  \       \\_ /   |_____/   )   /' /\  \\\  \/. .//' /\  \       
     __/  \\      |.  |    //      /   //  __'  \\.    ////  __'  \      
    /" \   :)     \:  |   |:  __   \  /   /  \\  \\\   //   /  \\  \     
   (_______/       \__|   |__|  \___)(___/    \___)\__/(___/    \___)                                                                           
-----------------------------------------------------------------------
                                                                v0.0.1

    Welcome to the Strava PowerShell Module
        Made by Christian Højsager aka ScriptingChris
        https://scriptingchris.tech



"@

    Clear-Host
    Write-Host $msg -ForegroundColor Yellow
    Write-Verbose -Message "Opening the Strava Authentication page in a browser"
    Write-Host 'A browser will now be opened with an authentication link. Here you need to press "Authenticate" then copy the access_token from the url in the page you will be redirected to:'
    $action = Read-Host -Prompt 'Do you want to continue? (Y/N): '

    if ($UseSecretStore.IsPresent) {
        # Clearing the old secrets if they already exists
        Write-Verbose -Message "Checking if secrets in StravaSecrets Vault already exists"
        $vault = Get-SecretVault -Name StravaSecrets
        if($vault) {
            $secretsToBeRemoved = @("client_id", "client_secret", "refresh_token", "access_token")
            foreach($secret in $secretsToBeRemoved) {
                Write-Verbose -Message "Checking if secret: $($secret) exists"
                try {
                    if(Get-Secret -Name $secret -Vault StravaSecrets) {
                        Remove-Secret -Name $secret -Vault StravaSecrets
                        Write-Verbose -Message "Secret $($secret) was removed"
                    }
                    else {
                        Write-Verbose -Message "Secret: $($secret), was not found, cannot be removed"
                    }
                }
                catch {
                    Write-Verbose -Message "No secret named: $($secret) exists"
                }
            }
        }
    }



    if ($action.ToLower() -eq "y"){
        Start-Process "http://www.strava.com/oauth/authorize?client_id=$($ClientId)&response_type=code&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=read_all,profile:read_all,activity:read_all,activity:write,profile:write"
        
        $tempAccessToken = Read-Host -Prompt "Please enter the access token you recieved in the redirected Url, from Strava: "
        Write-Host "Temporary access_token accepted."
        Write-Host "Retrieving Refresh Token"
        try {
            $result = Invoke-RestMethod `
            -Uri "https://www.strava.com/oauth/token?client_id=$($ClientId)&client_secret=$($ClientSecret)&code=$($tempAccessToken)&grant_type=authorization_code" `
            -Method "POST"
        }
        catch {
            Write-Error -Message "$($_.Exception.Response.StatusCode.value__) - HTTP: $($baseUrl)/$($Resource)"
            Write-Error -Message "$($_.Exception.Response.StatusDescription)"
            Write-Error -Message "Failed setting up the Strava authentication"
        }


        if ($result) {
            Write-Verbose -Message "Retrieving the new AccessToken"
            $authUrl = "https://www.strava.com/oauth/token"
            $tokenPayload = @{
                "client_id" = "$($ClientId)";
                "client_secret" = "$($ClientSecret)";
                "refresh_token" = "$($result.refresh_token)";
                "grant_type" = "refresh_token"
            }

            try {
                $accessToken = (Invoke-RestMethod -Uri $authUrl -Method "POST" -Body $tokenPayload).access_token
                Write-Verbose -Message "access_token retrieved: $($accessToken)"
            }
            catch {
                Write-Error -Message "Failed retriving an access_token"
                Write-Error -Message "$($_.Exception.Response.StatusDescription)"
                Exit
            }

            Write-Host "Successfully retrieved new access_token and refresh_token" -ForegroundColor Green
            Write-Host "access_token: $($accessToken)"
            Write-Host "refresh_token: $($result.refresh_token)"

            if ($UseSecretStore.IsPresent) {
                Write-Verbose -Message "Saving Strava API access_token to the PowerShell secret store"
                Write-Host "Creating a new Secret Store Vault named: StravaSecrets"
                Register-SecretVault -Name StravaSecrets -ModuleName Microsoft.PowerShell.SecretStore
                Write-Host "Successfully generated a new SecretVault: $($secretStore.Name)" -ForegroundColor Green
                Write-Host "You will be prompted to set a password for your secret store, you will be prompted for this password, everytime you run a strava command in "
                $secretStores = Get-SecretVault
                $secretStore = $secretStores | Where-Object {$_.Name -eq "StravaSecrets"}
                
                if ($secretStores.count -gt 1) {
                    $SecretStoreConfig = Get-SecretStoreConfiguration
                    if ($SecretStoreConfig.Authentication -eq "Password") {
                        Write-Host "You already have a password configuration for your Secret Store. you will be required to provide the password the first time you run a strava command in a new PowerShell session"
                    }
                    else {
                        Write-Host "You don't have a password configured for your secret store. Continuing without a password"
                    }
                }
                else {
                    Write-Host "You don't have any other Secret Stores configured than StravaSecrets."
                    Write-Host "You will now be prompted for entering a password for the secrets."
                    Write-Host "This password you will need everytime you run a strava command within a new PowerShell session"
                }

                Set-Secret -Name refresh_token -Secret "$($result.refresh_token)" -Metadata @{Purpose = 'Refresh Token used for Strava API'} -Vault StravaSecrets
                Write-Host "Setting secret: client_id"
                Set-Secret -Name client_id -Secret $ClientId -Metadata @{Purpose = 'client_id used for authenticating with Strava API'} -Vault StravaSecrets
                Write-Host "Setting secret: client_secret"
                Set-Secret -Name client_secret -Secret $ClientSecret -Metadata @{purpose = 'client_secret used for authenticating with Strava API'} -Vault StravaSecrets
                Write-Host "Setting secret: access_token"
                Set-Secret -Name access_token -Secret $accessToken -Metadata @{purpose = 'access_token used for authenticating all api calls to the strava api'} -Vault StravaSecrets

                try {
                    Write-Host ""
                    Write-Host "--------------------------------------------------"
                    Write-Host "Checking that everything was created successfully"

                    Write-Host ""
                    $r_token = Get-SecretInfo -Name refresh_token -Vault StravaSecrets
                    $c_id = Get-SecretInfo -Name client_id -Vault StravaSecrets
                    $c_secret = Get-SecretInfo -Name client_secret -Vault StravaSecrets
                    $a_token = Get-SecretInfo -Name access_token -Vault StravaSecrets
                    Write-Host "[v] - Successfuly generated and stored secret: $($r_token.Name), in vault: $($r_token.VaultName)" -ForegroundColor Green
                    Write-Host "[v] - Successfuly generated and stored secret: $($c_id.Name), in vault: $($c_id.VaultName)" -ForegroundColor Green
                    Write-Host "[v] - Successfuly generated and stored secret: $($c_secret.Name), in vault: $($c_secret.VaultName)" -ForegroundColor Green
                    Write-Host "[v] - Successfuly generated and stored secret: $($a_token.Name), in vault: $($a_token.VaultName)" -ForegroundColor Green
                    Write-Host "------------------------------------------------------------------------------------------------"
                    Write-Host "Successfully created all secrets" -ForegroundColor Green
                }
                catch {
                    Write-Error -Message "$($_)"
                }

            }
            else {
                Write-Host ""
                Write-Host ""
                Write-Host "access_token was retrieved" -ForegroundColor Yellow
                Write-Host "Please store the access token a safe place to use with the strava cmdlets" -ForegroundColor yellow
                Write-Host "--------------------------------------------------" -ForegroundColor Yellow
                Write-Host "access_token: $($access_token)"
            }
        }
    }
    else {
        Write-Warning -Message "You entered 'No' exiting Script"
    }
}
Export-ModuleMember -Function Set-StravaAuthentication
#EndRegion - Set-StravaAuthentication.ps1
#Region - Update-StravaActivity.ps1
function Update-StravaActivity {
    [CmdletBinding()]
    param (
        # Id of the activity to be updated
        [Parameter(Mandatory=$true, HelpMessage="The Id of the activity you want to update", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$Id,
        # The name of the activity
        [Parameter(Mandatory=$true, HelpMessage="Name of the activity you want to create", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$Name,
        # Sport type of activity. For example - Run, MountainBikeRide, Ride, etc.
        [Parameter(Mandatory=$true, HelpMessage="Sport type of activity. For example - Run, MountainBikeRide, Ride, etc.", ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet("Run", "Trail Run", "Walk", "Hike", 
            "Virtual Run", "Ride", "Mountain Bike Ride", "Gravel Bike Ride", "E-Bike Ride", "E-Mountain Bike Ride", "Velomobile", "Virtual Ride",
            "Canoe", "Kayak", "Kitesurf Session", "Row", "Stand Up Paddle", "Surf", "Swim", "Windsurf Session",
            "Ice Skate", "Alpine Ski", "Backcountry Ski", "Nordic Ski", "Snowboard", "Snowshoe",
            "Handcycle", "Inline Skate", "Rock Climb", "Roller Ski", "Wheelchair", "Crossfit", "Elliptical", "Stair Stepper","Weight Training", "Workout")]
        [String]$SportType,
        # Description of the activity
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName)]
        [String]$Description,
        # Set to mark as a trainer activity
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$Trainer,
        # Set to mark as commute
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$Commute,
        # Set to mute activity
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName)]
        [String]$HideFromHome
    )
    
    begin {
        Write-Verbose -Message "Initializing the cmdlet"
    }
    
    process {

        $resource = "activities/$($Id)"
        $method = "PUT"
        
        Write-Verbose -Message "Id: $($Id)"
        Write-Verbose -Message "Name: $($Name)"
        Write-Verbose -Message "SportType: $($SportType)"
        Write-Verbose -Message "Description: $($Description)"
        Write-Verbose -Message "Trainer: $($Trainer)"
        Write-Verbose -Message "Commute: $($Commute)"
        Write-Verbose -Message "HideFromHome: $($HideFromHome)"

        $payload = @{
            "name"                = $Name;
            "sport_type"          = $SportType;
            "description"         = $Description;
            "trainer"             = $Trainer;
            "commute"             = $Commute;
            "hide_from_home"      = $HideFromHome;
        }

        Write-Verbose -Message "Building Payload"
        $keysToRemove = New-Object System.Collections.ArrayList
        foreach($key in $payload.GetEnumerator()) {
            Write-Verbose -Message "Checking if key: $($key.Name) is false: $($key.Value)"
            if ($key.Value -eq $false) {
                $keysToRemove.Add($key.Name) | Out-Null
                Write-Verbose -Message "Removing key: $($key.Name) from payload since value = $($key.Value)"
            }
        }
        foreach($name in $keysToRemove) {
            $payload.Remove($name)
        }

        Write-Output -InputObject $paylaod
        $data = Invoke-StravaApi -Method $method -Resource $resource -Payload $payload
    }
    
    end {
        return $data
    }
}
Export-ModuleMember -Function Update-StravaActivity
#EndRegion - Update-StravaActivity.ps1
### --- PRIVATE FUNCTIONS --- ###
#Region - Get-StravaAthleteId.ps1
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
#EndRegion - Get-StravaAthleteId.ps1
#Region - Get-StravaSecrets.ps1
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
#EndRegion - Get-StravaSecrets.ps1
#Region - Invoke-StravaAPI.ps1
function Invoke-StravaApi {
    [CmdletBinding()]
    param (
        # Parameter for passing the HTTP method
        [Parameter(Mandatory=$true)]
        [ValidateSet("POST", "GET", "PUT", "DELETE")]
        [String]$Method,
        # Parameter for passing the url resource for HTTP endpoint
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [String]$Resource,
        # AccessToken for atuthentication to the Strava API
        [Parameter(Mandatory=$false)]
        [String]$AccessToken,
        # Json object of the payload to sent to the API
        [Parameter(Mandatory=$false)]
        [Object]$Payload,
        # SwitchParameter to define if paging should be used
        [Parameter(Mandatory=$false)]
        [Switch]$Pagination,
        # Page number
        [Parameter(Mandatory=$false)]
        [Int]$Page = 1,
        # Per page data objects
        [Parameter(Mandatory=$false)]
        [Int]$PerPage = 200
    )

    begin {

        if (!$AccessToken) {
            Write-Verbose -Message "access_token was  not provided"
            Write-Verbose -Message "Checking if Strava Secrets have been loaded"
            if(!$STRAVA_ACCESS_TOKEN) {
                $secrets = Get-StravaSecrets
                if ($secrets -eq $false) {
                    Write-Error -Message "No Access Token was provided. Run Set-StravaAuthentication to get startet"
                    Exit
                }
                Write-Verbose -Message "Loading Strava Secrets"
            }
            else {
                Write-Verbose -Message "Strava access_token where already loaded"
            }
        }
        
        $baseUrl = "https://www.strava.com/api/v3"
        Write-Verbose -Message "Setting the base url: $($baseUrl)"

        $headers = @{
            "Authorization" = "Bearer $($STRAVA_ACCESS_TOKEN)"
        }
        Write-Verbose -Message "Setting the API Call headers"
    }
    
    
    process {
        if($Pagination -eq $true) {
            Write-Verbose -Message "Invoking the API call with uri: $($baseUrl)/$($Resource)?page=$($page)&per_page=$($PerPage) and the Method: $($Method) with a payload"
            $Body = $Payload | ConvertTo-Json
            if($Body){
                Write-Verbose "Payload was create. Initiating HTTP request"
                try {
                    $result = Invoke-RestMethod -Uri "$($baseUrl)/$($Resource)?page=$($page)&per_page=$($PerPage)" -Method $Method -Headers $headers
                }
                catch {
                    Write-Warning -Message "HTTP Call Failed: $($_.Exception.Response.StatusCode.value__)"
                    $errorMessage = $($_)
                }
            }
            else {
                Write-Error -Message "No json body was found. Failed initiating HTTP request: $($baseUrl)/$($Resource)"
            }
        }
        elseif ($payload) {
            Write-Verbose -Message "Payload was added"
            Write-Verbose -Message "Invoking the API call with uri: $($baseUrl)/$($Resource) and the Method: $($Method)"
            try {
                $result = Invoke-RestMethod -Uri "$($baseUrl)/$($Resource)" -Method $Method -Headers $headers -Body $Payload
            }
            catch {
                Write-Warning -Message " HTTP Call Failed:$($_.Exception.Response.StatusCode.value__)"
                $errorMessage = $($_)
            }
        }
        else {
            Write-Verbose -Message "Invoking the API call with uri: $($baseUrl)/$($Resource) and the Method: $($Method)"
            Write-Verbose -Message "Invoking HTTP call to endpoint: $($baseUrl)/$($Resource) with HTTP Method: $($Method)"
            try {
                $result = Invoke-RestMethod -Uri "$($baseUrl)/$($Resource)" -Method $Method -Headers $headers
            }
            catch {
                Write-Warning -Message "HTTP Call Failed: $($_.Exception.Response.StatusCode.value__)"
                $errorMessage = $($_)
            }
        }
    }

    end {
        if(!($result)){
            Write-Error -Message " HTTP Status Code: $($statusCode) - URL: $($baseUrl)/$($Resource)"
            Write-Error -Message "$($errorMessage)"
        }
        else {
            return $result
        }
    }
}
#EndRegion - Invoke-StravaAPI.ps1
