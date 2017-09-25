function Set-TEApiConfig {
    <#
    .SYNOPSIS
    Sets authorization for current session
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Sets the authorization for the current PS session.  By default the apitoken will not be saved.
    Using the saveAuth switch will save the username/APItoken to the local machine.  For PS version 5
    this will be stored encrypted by default to the desktop.  The Save location can be set with the saveLocation
    parameter.  For opensource PS v.6 there does not seem to be a way to encrypt the file, this will be updated
    if this changes. 
    .EXAMPLE
    Set-TEApiConfig 
    This will set the auth for the session without saving
    .EXAMPLE
    Set-TEApiConfig -saveAuth
    This will set the auth for the session and save to disk, this will save time having to enter APIToken for each
    session.  The console will advise where the file is being saved, and if it is encrypted or not.
    .EXAMPLE
    Set-TEApiConfig -currentAuth
    Lists the current authentication that will be used for any TEApi module commands.
    .PARAMETER teUserName
    ThousandEyes username, can be passed to the function 
    .PARAMETER apiToken
    ThousandEyes API Token can be found at 
    https://app.thousandeyes.com/settings/account/?section=profile
    .PARAMETER saveAuth
    Switch to save the authorization to the local machine
    .PARAMETER saveLocation
    Option to save Auth to the specified location
    .PARAMETER currentAuth
    Lists the username currently being used to authenticate
    #>
    [cmdletBinding()]
    param(
        [string]$teUserName = $false,
        [string]$apiToken,
        [switch]$saveAuth,
        [string]$saveLocation = "$home\Desktop",
        [switch]$currentAuth
    )
    BEGIN {
        #Write-Output $script:TEApiToken
    } 

    PROCESS{
        $credsFile = "$saveLocation\$teUserName-PSCreds.txt"
        $secureCredsFile = "$saveLocation\$teUserName-SecPSCreds.txt"
        $FileExists = Test-Path $credsFile
        $secureFileExists = Test-Path $SecureCredsFile
        
        #VERBOSE Output for Variable Testing
        Write-Verbose $PSVersionTable.PSVersion.Major
        write-Verbose "Entered API Token is: $apiToken"
        Write-Verbose "Entered Username is: $teUserName"

        if($currentAuth){
            if($script:currentTeUsername){
                Write-Output "Current User: $script:currentTeUsername"; break
            }
            else{
                Write-Output "No Auth set"; break
            }
        }

        if ($teUserName -eq $false) {
            $teUserName = Read-Host "Enter TE username"
        }  

        if ($saveAuth) {
            Write-Verbose "Saved Auth flag detected entering saveAuth block"
            if ($PSVersionTable.PSVersion.Major -ne 6) {
                Write-Verbose "PowerShell Version is not equal to 6, using secureString to store auth key"
                if ($SecureFileExists -eq $false) {
                    Write-Verbose "There is no secureFile Found for this user, Prompting for Auth Token"
                    if ($apiToken) {
                        Write-Verbose "An api Token was specified as a parameter, using the inputed token"
                        "$apiToken" | ConvertTo-SecureString -AsPlainText -Force | Convertfrom-SecureString | Out-File $secureCredsFile -ErrorAction Stop
                    }
                    Else {
                        Write-Verbose "There was no API token entered as a parameter, ask for token"
                        Write-host 'Enter API Token: ' -ForegroundColor Red
                        Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $secureCredsFile -ErrorAction Stop
                        Write-host "Credential File Stored Encrypted at $secureCredsFile" -ForegroundColor green
                        
                    }
                    $authToken = Get-Content $SecurecredsFile | ConvertTo-SecureString
                    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($authToken)
                    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                }
                Else {
                    Write-Verbose "There is a secure File for this User, using the stored auth $secureCredsFile" 
                    $authToken = Get-Content $SecureCredsFile | ConvertTo-SecureString
                    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($authToken)
                    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                }
            }
            elseif ($FileExists) {
                Write-Verbose "Powershell version is 6 and there is a stored plaintext auth file, using the auth file $$credsFile"
                $plainPassword = Get-Content $credsFile
                }

            else {
                Write-Verbose "No Plain Text auth file found for user $teUserName, asking for token"
                $plainPassword = Read-Host "Enter your API Token" | Out-File $credsFile
                Write-host "Credential File Stored Unencrypted at $credsFile" -ForegroundColor Red
                }
            }
        elseif (-not($apiToken)) {
            Write-Verbose "No API Token entered, save auth not detected, prompt for API token"
            $plainPassword = Read-Host 'Enter your API Token' 
        }
        else{
            Write-Verbose "Username and Token passed, saveAuth not detected"
        }
        $authorization = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($teUserName + ":" + $plainPassword))
        $script:currentTeUsername = $teUserName
        $script:TEApiToken = $authorization
    }
}