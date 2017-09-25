function Send-TEApi {
  <#
    .SYNOPSIS
    Function that takes care of creating the Rest URL.  This function also invokes
    the Invoke-RestMethod and returns the json data as a PS-Object, Defaults to GET.
    .DESCRIPTION
    Built for the ThousandEyes API.  This function will take url construction parameters and invoke the rest method
    Returns a json object with requested data.
    .EXAMPLE
    $urlComponents = @('instant','dns','server')
    $body = New-TEApiInstantBody -agentId 3 -server thousandeyes.com -port 80 -pingType TCP | convertto-json

    Send-TEApi -urlComponents $urlComponents -method post -body $body
    .PARAMETER apiVer
    Api Version (5 or 6) value is taken from script parameter which is 6 by default
    .PARAMETER method
    (default is Get) use post value if invoking a post api call
    .PARAMETER urlComponents
    Array or URL components, this will include the test type, testID, get method etc.
    .PARAMETER body
    Used to send information as part of POST method
    .PARAMETER optionalParameters
    this can include optional parameters such as account ID, window, or timeframe
    .PARAMETER aid
    Account Group ID
    #>

  [CmdletBinding()]
  param(
    [int]$apiVer = "6",
    [string]$method = "Get",
    [string[]]$urlComponents,
    [string]$body,
    [string[]]$optionalParams,
    [string]$aid,
    [string]$auth = $Script:TEApiToken)

  BEGIN {
    if (-not ($Script:TEApiToken -or $auth)) {
      Write-Output 'Auth Token Not Set - Use Set-TEApiConfig to set auth token'
      break
    }

    $fullUrl = "https://api.thousandeyes.com/" + "v" + $apiVer #+ "/"
    $headers = @{ "accept" = "application/json"; "content-type" = "application/json"; "authorization" = "Basic " + "$auth" }


  }
  PROCESS {
    if ($aid) {
      $optionalParams = "aid=$aid"
    }
    <#  If block to check for url components, as they are passed as an array the function will add all components that are passed.
        This means we need to ensure that we are passing the components in to the function in the correct order.
        If no components are passed we will default to the status api call.#>
    if ($urlComponents.count -ne 0) {
      for ($i = 0; $i -lt $urlComponents.count; $i++) {
        $fullUrl = $fullUrl + "/" + $urlComponents[$i]
      }
    }
    else {
      $fullUrl = $fullUrl + "/status.json"
    }

    <#  If block to check for optional parameters.  As above we will add all parameters onto the url.  Order is not important on this one
        If there is more than one parameter then we need to add the & in between parameters.#>
   
    if ($optionalParams.count -eq 1) {
      $fullUrl = $fullUrl + "?" + $optionalParams[0]
    }
    elseif ($optionalParams.count -gt 1) {
      $fullUrl = $fullUrl + "?" + $optionalParams[0]
      for ($i = 1; $i -lt $optionalParams.count; $i++) {
        $fullUrl = $fullUrl + "&" + $optionalParams[$i]
      }
    }
    <# Try Block to catch any status messages returned from the api call  #>
    try {
      #Verbose output of URL that the function will call
      Write-Verbose $fullUrl
      if ($body) {
        $jsonObject = Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method $method -Body $body -ErrorAction Stop
      }
      else {
        $jsonObject = Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method $method
      }
    }
    # Catch block for catching any errors returned by the API
    catch {
      $result = $_.Exception.Response.GetResponseStream()
      $reader = New-Object System.IO.StreamReader ($result)
      $UsefulData = $reader.ReadToEnd();

      #write-output $_ -ForegroundColor Red
      $errorMessage = [regex]::match($UsefulData,'(?<=again. )(?s)(.*?)(?="})').Value
      Write-Host $_ " $errorMessage " -ForegroundColor Red
      #$jsonObject = $errorMessage
    }
   

      return $jsonObject
  
    
  }
  END {
  }
}
