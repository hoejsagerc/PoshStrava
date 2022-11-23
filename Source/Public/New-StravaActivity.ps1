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