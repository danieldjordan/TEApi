function Restore-TEApiDnsServer {
     <#
    .SYNOPSIS
    Restore Backed up test created by Backup-TEApiTest
    .DESCRIPTION
   
    .EXAMPLE
    
    .EXAMPLE
   
    .PARAMETER apiVersion
    
    .PARAMETER aid
    Account Group ID
    .PARAMETER id
    Test ID for Restore
    .PARAMETER restoreLocation
    Location to restore from, defaults to $PWD
    #>
[CmdletBinding()]
    param(
        [int]$apiVersion = 6,

        [string]$aid,

        [Parameter(Mandatory=$true, 
                    ValueFromPipelineByPropertyName=$True,
                    Position=0)]
        [object]$test
    )
    BEGIN {}
    PROCESS {
            $body = @{}
            
            $urlComponents = @('tests','dns-server','new')

            $body.testName              =   $test.testName
            $body.agents                =   $test.agents | Select-Object agentId
            $body.dnsServers            =   $test.dnsServers | Select-Object serverName
            $body.domain                =   $test.domain
            $body.interval              =   $test.interval
            $body.recursiveQueries      =   $test.recursiveQueries
            $body.networkMeasurements   =   $test.networkMeasurements
            $body.mtuMeasurements       =   $test.mtuMeasurements
            $body.bandwidthMeasurements =   $test.bandwidthMeasurements
            $body.bgpMeasurements       =   $test.bgpMeasurements
            $body.alertsEnabled         =   $test.alertsEnabled
            $body.bgpMonitors           =   $test.bgpMonitors | Select-Object monitorId
            $body.alertRules            =   $test.alertRules | Select-Object ruleId

            $jsonBody = $body | ConvertTo-Json
            Write-Output $jsonBody
            $results = send-TEApi -method post -urlcomponents $urlComponents -body $jsonBody -aid $aid
            #Write-host "Test Created Successfully" -ForegroundColor Green
            Write-Output $results.test
    }
    END {}
}
