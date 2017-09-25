function Get-TEApiStatus{
    <#
    .SYNOPSIS
    Function to test whether the API is up or not.
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Will return true or false based on whether API is up or not
    .EXAMPLE
    Get-TEAPiStatus
    Will Return $true if a timestamp is returned, false if not.
    .PARAMETER apiVersion
    API version defaults to version 6
    #>
        [CmdletBinding()]
    param(
        [int]$apiVersion = 6
    )
    BEGIN{}
    PROCESS{
        $apiStatus = Send-TEApi -apiver $apiVersion

        if ($apiStatus.timestamp) {
            $apiUp = $true
        }
    
        else {
            $apiUp = $false
        }        
    
        Write-Output $apiUp
    }
    END{}
}