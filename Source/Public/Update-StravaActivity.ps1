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