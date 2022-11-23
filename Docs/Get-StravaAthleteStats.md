---
external help file: PoshStrava-help.xml
Module Name: PoshStrava
online version:
schema: 2.0.0
---

# Get-StravaAthleteStats

## SYNOPSIS
Cmdlet for retrieving the authenticated athletes stats

## SYNTAX

```
Get-StravaAthleteStats [-OutputJson] [-Path <String>] [-AccessToken <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will query the api to first find the currently authenticated atheletes id, and return the athletes stats

## EXAMPLES

### EXAMPLE 1
```
Get-StravaAthleteStats
```

This example will output an object containing the athletes stats

## PARAMETERS

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
