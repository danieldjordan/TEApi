function New-TEApiTest 
{
    [CmdletBinding()]
    Param(
        #####   Common Parameters       #####
        [Parameter( Mandatory=$true, Position = 0)]
        [string]$testName,

        [Parameter( HelpMessage="Array of Group objects")]
        [array]$groups,

        [Parameter( HelpMessage="enable alerts, defaults to false")]
        [switch]$alertsEnabled,

        [Parameter( HelpMessage="Array of Alert Rule IDs")]
        [array]$alertRules,

        [Parameter( Dontshow, HelpMessage="Body from other functions")]
        [hashtable[]]$inputBody,

        [Parameter( Dontshow, HelpMessage="Type of Test to Create")]
        [string]$testType,
        #####   BGP Test Section        #####
        [Parameter(ParameterSetName="CreateBGPTest",
                    Mandatory=$true)]
        [switch]$createBGPTest,

        [Parameter(ParameterSetName="CreateBGPTest",
                    Mandatory=$true)]
        [string]$prefix,

        [Parameter(ParameterSetName="CreateBGPTest")]
        [switch]$includeCoveredPrefix,
        #####   DNS Server Test Type    #####
        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true,
                    Position=0)]
        [switch]$CreateDNSServerTest,

        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true,
                    Position=0)]
        [switch]$CreateDNSTraceTest,
        #####   DNS Server Parameters   #####
        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [array]$agents,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [switch]$bandwidthMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [switch]$bgpMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [array]$bgpMonitors,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]            
        [array]$dnsServers,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [string]$domain,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [int]$interval,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [switch]$mtuMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [switch]$networkMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [switch]$recursiveQueries,

        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [validateset('A','AAAA','ANY','CNAME','DNSKEY','DS','MX','NS','NSE','NULL','PTR','RRSIG','SOA','TXT')]
        [string]$type


    )

    Begin{}

    Process{
        if (-not $InputBody){
            $body = @{}

            switch ($PSBoundParameters.keys) {
                'testName'              { $body.testName                = $testName}
                'groups'                { $body.groups                  = $groups}
                'alertsEnabled'         { $body.alertsEnabled           = $true}
                'alertRules'            { $body.alertRules              = $alertRules}
                'prefix'                { $body.prefix                  = $prefix}
                'includeCoveredPrefix'  { $body.includeCoveredPrefix    = $true}
                'agents'                { $body.agents                  = $agents}
                'bandwidthMeasurements' { $body.bandwidthMeasurements   = $true}
                'bgpMeasurements'       { $body.bgpMeasurements         = $true}
                'bgpMonitors'           { $body.bgpMonitors             = $bgpMonitors}
                'dnsServers'            { $body.dnsServers              = $dnsServers}
                'domain'                { $body.domain                  = $domain}
                'interval'              { $body.interval                = $interval}
                'mtuMeasurements'       { $body.mtuMeasurements         = $true}
                'networkMeasurements'   { $body.networkMeasurements     = $true}
                'recursiveQueries'      { $body.recursiveQueries        = $true}
                'type'                  { $body.type                    = $type}
                

            }
        }
        if ($inputBody){
            $body = $inputBody
        }
        $jsonBody = $body | ConvertTo-Json 
        $urlComponentsList = New-Object System.Collections.Generic.List[System.Object]
        $urlComponentsList.add('tests')


        switch ($PSBoundParameters.keys) {
            'createDnsServerTest'   { $urlComponentsList.add('dns-server')
                                         Write-Output "DNS-Server Test"}     
        }
        
        $urlComponentsList.add('new')
        $urlComponents = $urlComponentsList.ToArray()
        Write-Output $urlComponents
        Write-Output $body
        Write-Output $jsonbody
        #$results = send-TEApi -method post -urlcomponents $urlComponents -body $jsonBody
        #Write-host "Test Created Successfully" -ForegroundColor Green
        Write-Output $results.test
    }
    End{}
}