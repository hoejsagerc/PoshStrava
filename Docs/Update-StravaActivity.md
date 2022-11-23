---
external help file: PoshStrava-help.xml
Module Name: PoshStrava
online version: https://github.com/ScriptingChris/PoshStrava/blob/main/README.md
schema: 2.0.0
---

# Update-StravaActivity

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Update-StravaActivity [-Id] <String> [-Name] <String> [-SportType] <String> [[-Description] <String>]
 [-Trainer] <String> [-Commute] <String> [[-HideFromHome] <String>] [<CommonParameters>]
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

### -Commute
{{ Fill Commute Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Description
{{ Fill Description Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -HideFromHome
{{ Fill HideFromHome Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Id
The Id of the activity you want to update

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
Name of the activity you want to create

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SportType
Sport type of activity.
For example - Run, MountainBikeRide, Ride, etc.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Run, Trail Run, Walk, Hike, Virtual Run, Ride, Mountain Bike Ride, Gravel Bike Ride, E-Bike Ride, E-Mountain Bike Ride, Velomobile, Virtual Ride, Canoe, Kayak, Kitesurf Session, Row, Stand Up Paddle, Surf, Swim, Windsurf Session, Ice Skate, Alpine Ski, Backcountry Ski, Nordic Ski, Snowboard, Snowshoe, Handcycle, Inline Skate, Rock Climb, Roller Ski, Wheelchair, Crossfit, Elliptical, Stair Stepper, Weight Training, Workout

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Trainer
{{ Fill Trainer Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
