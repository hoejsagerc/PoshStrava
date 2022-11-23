---
external help file: PoshStrava-help.xml
Module Name: PoshStrava
online version:
schema: 2.0.0
---

# New-StravaActivity

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
New-StravaActivity [-Name] <String> [-SportType] <String> [-StartDate] <DateTime> [-ElapsedTime] <String>
 [[-Type] <String>] [[-Description] <String>] [[-Distance] <Single>] [-Trainer] [-Commute] [-HideFromHome]
 [[-AccessToken] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AccessToken
{{ Fill AccessToken Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Commute
{{ Fill Commute Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
{{ Fill Description Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Distance
{{ Fill Distance Description }}

```yaml
Type: Single
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ElapsedTime
Elapsed time should be in seconds

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HideFromHome
{{ Fill HideFromHome Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the activity you want to create

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SportType
Sport type of activity.
For example - Run, MountainBikeRide, Ride, etc.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Run, Trail Run, Walk, Hike, Virtual Run, Ride, Mountain Bike Ride, Gravel Bike Ride, E-Bike Ride, E-Mountain Bike Ride, Velomobile, Virtual Ride, Canoe, Kayak, Kitesurf Session, Row, Stand Up Paddle, Surf, Swim, Windsurf Session, Ice Skate, Alpine Ski, Backcountry Ski, Nordic Ski, Snowboard, Snowshoe, Handcycle, Inline Skate, Rock Climb, Roller Ski, Wheelchair, Crossfit, Elliptical, Stair Stepper, Weight Training, Weight Training, Workout

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartDate
Must be in ISO 8601 Standard =\> '2022-08-10T11:55:10.9626456+02:00' - You can use {Get-Date -Format 'o'}

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Trainer
{{ Fill Trainer Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
{{ Fill Type Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
