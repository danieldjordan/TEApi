function Get-TEApiTestData {
     <#
    .SYNOPSIS
    Function for getting test Data
    STATUS - Not Complete
    .DESCRIPTION
    Returns the data from a specific test, if no options specified the current round of data will be returned
    .EXAMPLE
    
    .EXAMPLE
    
    .PARAMETER apiVersion
    API version defaults to version 6
    .PARAMETER aid
    Account Group ID
    .PARAMETER testId
    testId
    .PARAMETER window
    Specifies a window of time for active alerts (optional) [0-9]+[smhdw]
    .PARAMETER timeRange 
    Specifies an explicit start and end time (optional) YYYY-mm-ddTHH:MM:SS&to=YYYY-mm-ddTHH:MM:SS
    .PARAMETER direction
    Direction of data to retrieve for end-to-end metrics test
    #>
    [CmdletBinding()]
    param(
        [int]$apiVersion = 6,

        [string]$aid,

        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="test ID")]
        [string[]]$testId,

        [Parameter(Mandatory=$False,
                   ValueFromPipeline=$true,
                   HelpMessage="test ID")]
        [int[]]$agentId,

        [Parameter(Mandatory=$False,
                   ValueFromPipeline=$true,
                   HelpMessage="round ID")]
        [int[]]$roundId,

        [Parameter(HelpMessage="window")]
        [validateScript({
            If ($_ -match "[0-9]+[smhdw]") {
                $True
            }
            else {
                Throw "$_ must start with digit and include s,m,h,d, or w "
            }
        })]
        [string]$window,

        [Parameter(HelpMessage="Explicit time Range <from>")]
        [string]$timeRangeFrom,

        [Parameter(HelpMessage="Explicit time Range<to>")]
        [string]$timeRangeTo,

        [switch]$openUrl,

        [switch]$bypass,

        [switch]$transDetail

    )
    BEGIN {}
    PROCESS {
        if (($timeRangeFrom -and (-not $timeRangeTo)) -or ($timeRangeTo -and (-not $timeRangeFrom))) {
            Write-Output "Time Range must include both a timeRangeFrom and timeRangeTo"; break
        }

        $windowParam = 'window='+$window 
        $timeRangeFromParam = 'from='+$timeRangeFrom
        $timeRangeToParam = 'to='+$timeRangeTo

        if (-not $bypass){
            $testType = Send-TEApi $apiVersion -urlComponents:@( "tests","$testId") -aid $aid | Select-Object -ExpandProperty test | Select-Object type
            
            switch ($testType.type) {
                    'agent-to-agent'                { Send-TEApi $apiVersion -urlComponents:@( "net","metrics","$testId") -aid $aid}
                    'agent-to-server'               { Send-TEApi $apiVersion -urlComponents:@( "net","metrics","$testId") -aid $aid}
                    'http-server'                   { Send-TEApi $apiVersion -urlComponents:@( "web","http-server","$testId") -aid $aid}
                    'page-load'                     { Send-TEApi $apiVersion -urlComponents:@( "web","page-load","$testId") -aid $aid}
                    'transactions'                  { if ($transDetail){  $testData = Send-TEApi $apiVersion -urlComponents:@( "web","transactions","$testId","$agentId","$roundId") -aid $aid}
                                                    else{$testData = Send-TEApi $apiVersion -urlComponents:@( "web","transactions","$testId") -optionalParams:@("aid=$aid","$timeRangeFromParam", "$timeRangeToParam")}}
                                                                
            }}
        else{
            if ($transDetail){  $testData = Send-TEApi $apiVersion -urlComponents:@( "web","transactions","$testId","$agentId","$roundId") -aid $aid}
            else{$testData = Send-TEApi $apiVersion -urlComponents:@( "web","transactions","$testId") -optionalParams:@("aid=$aid","$timeRangeFromParam", "$timeRangeToParam")}                                                     
        }

        Write-Output $testData
    }
}
