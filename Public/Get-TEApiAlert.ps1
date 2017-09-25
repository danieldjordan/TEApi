function Get-TEApiAlert {
     <#
    .SYNOPSIS
    Function for getting alerts 
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Grabs either a list of all alert rules, active alerts, or details for a specific alert
    .EXAMPLE
    Get-TEApiAlert
    This will use the default behavior and return all Active Alerts
    .EXAMPLE
    Get-TEApiAlert -alertRules
    .PARAMETER apiVersion
    API version defaults to version 6
    .PARAMETER aid
    Account Group ID
    .PARAMETER id
    Alert ID
    .PARAMETER alertRules
    returns a list of alert Rules configured on the account
    .PARAMETER window
    Specifies a window of time for active alerts (optional) [0-9]+[smhdw]
    .PARAMETER timeRange 
    Specifies an explicit start and end time (optional) YYYY-mm-ddTHH:MM:SS&to=YYYY-mm-ddTHH:MM:SS
   
    #>
    [CmdletBinding(DefaultParameterSetName='AlertList')]
    param(
        [int]$apiVersion = 6,

        [string]$aid,

        [Parameter(ParameterSetName="AlertDetails",
                   Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="Agent ID")]
        [string[]]$id,

        [Parameter(ParameterSetName="alertRules",
                   Mandatory=$True,
                   HelpMessage="Bgp Monitor List")]
        [switch]$alertRules,

        [Parameter(ParameterSetName="AlertList",
                   HelpMessage="window")]
        [validateScript({
            If ($_ -match "[0-9]+[smhdw]") {
                $True
            }
            else {
                Throw "$_ must start with digit and include s,m,h,d, or w "
            }
        })]
        [string]$window,

        [Parameter(ParameterSetName="AlertList",
                   HelpMessage="Explicit time Range <from>")]
        [string]$timeRangeFrom,

        [Parameter(ParameterSetName="AlertList",
                   HelpMessage="Explicit time Range<to>")]
        [string]$timeRangeTo

    )
    BEGIN {}
    PROCESS {
        if (($timeRangeFrom -and (-not $timeRangeTo)) -or ($timeRangeTo -and (-not $timeRangeFrom))) {
            Write-Output "Time Range must include both a timeRangeFrom and timeRangeTo"; break
        }

        $windowParam = 'window='+$window 
        $timeRangeFromParam = 'from='+$timeRangeFrom
        $timeRangeToParam = 'to='+$timeRangeTo
        if ($id){
            ForEach ($alert in $id) {
                
                $alertDetailsObject = Send-TEApi $apiVersion -urlComponents:@("alerts", "$alert") -aid $aid
                Write-Output $alertDetailsObject.alert
            }
        }
        elseif ($alertRules -eq $true) {
            $alertDetailsObject = Send-TEApi $apiVersion -urlComponents:@("alert-rules") -aid $aid
            Write-Output $alertDetailsObject.alertRules
        }

        elseif ($window) {
            $alertListObject = Send-TEApi $apiVersion -urlComponents:@("alerts") -aid $aid -optionalParams:@("$windowParam")
            Write-Output $alertListObject.alert
        }
        elseif ($timeRangeFrom) {
            $alertListObject = Send-TEApi $apiVersion -urlComponents:@("alerts") -aid $aid -optionalParams:@("$timeRangeFromParam", "$timeRangeToParam")
            Write-Output $alertListObject.alert
        }
        else {
            $alertListObject = Send-TEApi $apiVersion -urlComponents:@("alerts") -aid $aid 
            Write-Output $alertListObject
        }
    }
    END {}
}
