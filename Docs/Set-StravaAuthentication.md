---
external help file: PoshStrava-help.xml
Module Name: PoshStrava
online version: https://github.com/ScriptingChris/PoshStrava/blob/main/README.md
schema: 2.0.0
---

# Set-StravaAuthentication

## SYNOPSIS
Function for setting up your strava authentication for the first time.

## SYNTAX

```
Set-StravaAuthentication [[-ClientId] <String>] [[-ClientSecret] <String>] [-UseSecretStore]
 [<CommonParameters>]
```

## DESCRIPTION
This function requires that you have alreaded create the API application in your Strava Account.

if you haven't already created a Strava API App you will need to go to url: https://www.strava.com/settings/api
Once you have created the API App you should be able to find your API setting under: Strava profile --\>
Settings --\> My API Application

Under the panel 'My API Application' you will be able to find: Client ID and Client Secret.
These two values you will
need to use for this function.

When you run the function, a web browser will be opened.
Here you will be prompted to Authenticate your application.
Once you've pressed the Authenticate button you will be redirected to a localhost page.
On this page you will need to 
take the 'code' parameter in the URL.

It will look similar to: code=32e0113c8a5f7b704570349619c24fa567770e27    \<-- You should not take the 'code=' part of the url.
Only copy the code.

From this code you will generate a new refresh_token which will be used for every api call to authenticate to the API.

To save the client_id, client_secret & refresh_token, the function will install a new Secrets Vault named StravaSecrets.
If you already have a vault canfigured it will use the password for this vaul, otherwise you will be prompted to create a 
new password.
This password you will need to use everytime you run a strava command in a new PowerShell session.

This function should only be run the first time you want to use the PowerShell Module

## EXAMPLES

### EXAMPLE 1
```
Set-StravaAuthentication -ClientId "8121231" -ClientSecret "kl2n1lkn66kln31lk1243kn41n423114lknasdp9"
```

This example will Authenticate you to Strava and store the authentication tokens and secret in a PowerShell Secrets Vault.

## PARAMETERS

### -ClientId
The Client Id found on your Strava Account.
Go to Settings --\> My API Application --\> Client ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
The Client Secret found on your Strava Account.
Go to Settings --\> My API Application --\> Client Secret

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSecretStore
{{ Fill UseSecretStore Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/ScriptingChris/PoshStrava/blob/main/README.md](https://github.com/ScriptingChris/PoshStrava/blob/main/README.md)

