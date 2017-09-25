function Get-TEApiTest {
     <#
    .SYNOPSIS
    Function for getting tests configured for the account group
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Grabs either a list of all tests, details for a specific test, or all tests of a specific type
    .EXAMPLE
    Get-TEApiTest
    This will use the default behavior and return all tests for the account group
    .EXAMPLE
    Get-TEApiTest -id <testId>
    .PARAMETER apiVersion
    API version defaults to version 6
    .PARAMETER aid
    Account Group ID
    .PARAMETER id
    returns the details for a specific test
    .PARAMETER TestType
    Returns all tests for a specific testType. Valid values are agent-to-server
    agent-to-agent
    bgp
    http-server
    page-load
    transactions
    ftp-server
    dns-trace
    dns-server
    dns-dnssec
    dnsp-domain
    dnsp-server
    voice   
    #>
    [CmdletBinding(DefaultParameterSetName='TestList')]
    param(
        [int]$apiVersion = 6,

        [string]$aid,

        [Parameter(ParameterSetName="TestDetails",
                   Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="Agent ID")]
        [string[]]$id,

        [Parameter(ParameterSetName="TestType",
                   Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="Test Type")]
        [validateset('agent-to-agent','bgp','http-server','page-load','transactions','ftp-server','dns-trace',
                     'dns-server','dns-dnssec','dnsp-domain','dnsp-server','voice')]
        [string[]]$testType

    )
    BEGIN {}
    PROCESS {
        if ($id){
            ForEach ($test in $id) {
                
                $testDetailsObject = Send-TEApi $apiVersion -urlComponents:@("tests", "$test") -aid $aid
                Write-Output $testDetailsObject.test
            }
        }
        elseif ($testType){
            ForEach ($type in $testType) {
               
                $testTypeObject = Send-TEApi $apiVersion -urlComponents:@("tests", "$testType") -aid $aid
                Write-Output $testTypeObject.test
            }
        }
        else {
            $testListObject = Send-TEApi $apiVersion -urlComponents:@("tests") -aid $aid
            Write-Output $testListObject.test
        }
    }
    END {}
}
