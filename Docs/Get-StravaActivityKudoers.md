---
external help file: PoshStrava-help.xml
Module Name: PoshStrava
online version:
schema: 2.0.0
---

# Get-StravaActivityKudoers

## SYNOPSIS
Cmdlet for retrieving all comments on an activity

## SYNTAX

```
Get-StravaActivityKudoers -Id <Int64> [-OutputJson] [-Path <String>] [-Page <Int32>] [-PerPage <Int32>]
 [-AccessToken <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will return all the kudos added to a Strava Activity.
The cmdlet can output the result to a json file

## EXAMPLES

### EXAMPLE 1
```
Get-StravaActivityKudoers -Id 7551294509
```

This example will output an object containing all the kudos created on the spicific activity with the Id 7551294509

### EXAMPLE 2
```
Get-StravaActivityKudoers -Id 7557894309 -OutputJson -Path ~/temp/strava_output.json
```

This example will output all the kudos from an activity to a json file and create the file in the path
~/temp/strava_output.json

## PARAMETERS

### -Id
The Activity Id of a specific Strava Activity

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputJson
Switch parameter to define if the output from the command should be saved to a json file

```yaml
Type: SwitchParameter
Parameter Sets: (All)
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
Parameter Sets: (All)
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
Parameter Sets: (All)
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
Parameter Sets: (All)
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
