---
external help file: PoshStrava-help.xml
Module Name: PoshStrava
online version:
schema: 2.0.0
---

# Get-StravaActivities

## SYNOPSIS
Cmdlet for retriving either a single Strava activity or all the Strava activies from your Strava account

## SYNTAX

### all (Default)
```
Get-StravaActivities [-Page <Int32>] [-PerPage <Int32>] [-AccessToken <String>] [<CommonParameters>]
```

### single
```
Get-StravaActivities [-Id <Int64>] [-IncludeAllEfforts] [-AccessToken <String>] [<CommonParameters>]
```

### output
```
Get-StravaActivities [-OutputJson] [-Path <String>] [-AccessToken <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet can be used to retrieve a single Strava activity by the Activity Id, or you can 
retrieve all the activites from your account.

## EXAMPLES

### EXAMPLE 1
```
Get-StravaActivities -Verbose
```

This example will retrieve all the activities from your Strava account, and provide Verbose information

### EXAMPLE 2
```
Get-StravaActivities -Id 1736127843 -IncludeAlEfforts
```

This example will retrieve all details on the specific Strava activity with the Id 1736127843

### EXAMPLE 3
```
Get-StravaActivities -OutputJson -Path "~/temp/activities_output.json"
```

This example will save a json file with all the strava activies.
It will store the file in the path
"~/temp/activities_output.json"

## PARAMETERS

### -Id
The Activity Id of a specific Strava Activity

```yaml
Type: Int64
Parameter Sets: single
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -IncludeAllEfforts
Switch to define if you want to retrieve all the segment efforts you made on the specific Strava
activity.
This switch should be used combined with the Id parameter

```yaml
Type: SwitchParameter
Parameter Sets: single
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputJson
Switch parameter to define if the output from the command should be saved to a json file

```yaml
Type: SwitchParameter
Parameter Sets: output
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
If you defined the switch OutputJson, you can define a path to where the file should be stored.
If no path is defined, the file will be saved in your current directory as ./strava_output.json

```yaml
Type: String
Parameter Sets: output
Aliases:

Required: False
Position: Named
Default value: ./strava_output.json
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
You can define the Page number for the pagination when querying the Strava API by default it will start
on page 1

```yaml
Type: Int32
Parameter Sets: all
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerPage
You can define how many activities you want listed on each page queried from the Strava API

```yaml
Type: Int32
Parameter Sets: all
Aliases:

Required: False
Position: Named
Default value: 200
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessToken
Access token to authenticate with the Strava API.
If you used the parameter switch -UseSecretStore when you run 
the cmdlet Set-StravaAuthentication.
The access token is stored in the PowerShell secret store, and should not 
be provided to this cmdlet.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
