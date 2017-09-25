function New-TEApiTestBGP
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$true, Position = 0)]
        [string]$testName,

        [Parameter(ParameterSetName="CreateBGPTest",
                    Mandatory=$true)]
        [switch]$createBGPTest,

        [Parameter(ParameterSetName="CreateBGPTest",
                    Mandatory=$true)]
        [string]$prefix,

        [Parameter(ParameterSetName="CreateBGPTest")]
        [bool]$includeCoveredPrefix,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true,
                    Position=0)]
        [switch]$CreateDNSServerTest,

        [Parameter(ParameterSetName="UpdateDNSServerTest",
                    Mandatory=$true,
                    Position=0)]
        [switch]$UpdateDNSServerTest,

        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true,
                    Position=0)]
        [switch]$CreateDNSTraceTest,

        [Parameter(ParameterSetName="UpdateDNSTraceTest",
                    Mandatory=$true,
                    Position=0)]
        [switch]$UpdateDNSTraceTest,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="UpdateDNSTraceTest")]
        [array]$agents,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [bool]$bandwidthMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [bool]$bgpMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [array]$bgpMonitors,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]            
        [array]$dnsServers,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [string]$domain,

        [Parameter(ParameterSetName="CreateDNSServerTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="UpdateDNSTraceTest")]
        [int]$interval,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [bool]$mtuMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [bool]$networkMeasurements,

        [Parameter(ParameterSetName="CreateDNSServerTest")]
        [Parameter(ParameterSetName="UpdateDNSServerTest")]
        [bool]$recursiveQueries,

        [Parameter(ParameterSetName="CreateDNSTraceTest",
                    Mandatory=$true)]
        [validateset('A','AAAA','ANY','CNAME','DNSKEY','DS','MX','NS','NSE','NULL','PTR','RRSIG','SOA','TXT')]
        [string]$type,

        [string]$server,
        [int]$port,

        [validateset('TCP','ICMP')]
        [string]$pingType,

        [string]$url,
        [int]$testId
    )

    Begin{}

    Process{
        $body = @{}

        switch ($PSBoundParameters.keys) {
            'testName'              { $body.testName                = $testName}
            'agents'                { $body.agents                  = $agents}
            'prefix'                { $body.prefix                  = $prefix}
            'includeCoveredPrefix'  { $body.includeCoveredPrefix    = $includeCoveredPrefix}
            'bandwidthMeasurements' { $body.bandwidthMeasurements   = $bandwidthMeasurements}
            'bgpMeasurements'       { $body.bgpMeasurements         = $bgpMeasurements}
            'bgpMonitors'           { $body.bgpMonitors             = $bgpMonitors}
            'dnsServers'            { $body.dnsServers              = $dnsServers}
            'interval'              { $body.interval                = $interval}
            'mtuMeasurements'       { $body.mtuMeasurements         = $mtuMeasurements}
            'networkMeasurements'   { $body.networkMeasurements     = $networkMeasurements}
            'recursiveQueries'      { $body.recursiveQueries        = $recursiveQueries}
            'agentId'               { $body.agentId                 = $agentId}
            'server'                { $body.server                  = $server}
            'port'                  { $body.port                    = $port}
            'pingType'              { $body.pingType                = $pingType}
            'url'                   { $body.url                     = $url}
            'domain'                { $body.domain                  = $domain}
            'type'                  { $body.type                    = $type}
            'testId'                { $body.testId                  = $testId}
        }

        $jsonBody = $body | ConvertTo-Json 
        #Write-Output $jsonBody
        $urlComponentsList = New-Object System.Collections.Generic.List[System.Object]
        $urlComponentsList.add('tests')


        switch ($PSBoundParameters.keys) {
            'createDnsServerTest'   { $urlComponentsList.add('dns-server')}     
        }
        $urlComponentsList.add('new')
        $urlComponents = $urlComponentsList.ToArray()
        #Write-Output $urlComponents
        $results = send-TEApi -method post -urlcomponents $urlComponents -body $jsonBody
        #Write-host "Test Created Successfully" -ForegroundColor Green
        Write-Output $results.test
    }
    End{}
}