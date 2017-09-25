function Restore-TEApiTest {
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

        [Parameter(ParameterSetName="TestBackup",
                   Position=0,
                   Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="Agent ID")]
        [string[]]$id,

        [Parameter(ParameterSetName="TestBackup",
                   HelpMessage="Restore File Location")]
        [string]$restoreLocation = $PWD

    )
    BEGIN {}
    PROCESS {
            ForEach ($test in $id) {
                $testRestore = $restoreLocation + "\$test" + ".xml"
                $testDetailsObject = Import-Clixml -Path  $testRestore

                $testObject = $testDetailsObject.test

                $body = @{}

                switch (($testObject | Get-member).name) {
                    'testName'      {$body.testName     =   $testObject.testname}
                    'dnsServers'    {$body.dnsServers   =   $testObject.dnsServers}
                    Default {}
                }

                switch ($testObject.type) {
                    'page-load'         { Write-Output "page Load Test";  break}
                    'agent-to-server'   { Write-Output "agent to Server";  break}
                    'agent-to-agent'    { Write-Output "agent to agent";  break}
                    'bgp'               { Write-Output "bgp";  break}
                    'http-server'       { Write-Output "http server";  break}
                    'transactions'      { Write-Output "transactions";  break}
                    'ftp-server'        { Write-Output "ftp-server";  break}
                    'dns-trace'         { Write-Output "dns-trace";  break}
                    'dns-server'        { Write-Output $body} #New-TEApiTest $testObject;  break}
                    'dns-dnssec'        { Write-Output "dns-dnssec";  break}
                    'dnsp-domain'       { Write-Output "dnsp-domain";  break}
                    'dnsp-server'       { Write-Output "dnsp-server";  break}
                    'voice'             { Write-Output "voice";  break}
                    Default {}
                }
            }
    }
    END {}
}