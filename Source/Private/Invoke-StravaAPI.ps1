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
