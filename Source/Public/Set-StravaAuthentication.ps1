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