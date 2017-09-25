function New-TEApiInstantTest 
{
    <#
    .SYNOPSIS
    Function for running instant tests on TE platform
    .DESCRIPTION
    Instant test function.  Function will return a json object of the test results.
    .EXAMPLE
    New-TEApiInstantTest 
    .PARAMETER NetPing
    Run a Ping test, takes no value.  Additional Parameters are (agentId, server, port, pingType)
    .PARAMETER NetPath
    Run a Path-Visualization test, takes no value.  Additional Parameters are (agentId, server, port, pingType)
    .PARAMETER NetTCP
    Run a TCP Connect Test, takes no value.  Additional Parameters are (agentId, server, port)
    .PARAMETER NetBw
    Run a Bandwidth test, takes no value.  Additional Parameters are (agentId, server, port, pingType)
    .PARAMETER WebHttp
    Run a HTTP server test, takes no value.  Additional required Parameters are (agentId, url) optional parameters are (username, password
    useNtlm, postBody, verifySSLCertificate, sslVersionId, headers) 
    .PARAMETER agentId
    Agent that will run the test, can be pulled from the /agents api endpoint
    .PARAMETER server
    Target for test
    .PARAMETER port
    If ping type is TCP the port to use for the target
    .PARAMETER pingType
    ICMP or TCP
    .PARAMETER url
    target for test
    .PARAMETER domain
    Domain target for DNS test
    .PARAMETER type
    DNS record type for DNS tests
    .PARAMETER testId
    testId for transaction test cal be pulled from /tests endpoint
    .PARAMETER username
    username for basic or NTLM authentication
    .PARAMETER pw
    password for basic or NTLM authentication
    .PARAMETER useNtlm
    1 to user NTLM, default is 0 Must be set to enable username/password
    .PARAMETER postBody
    include this data when using a POST request method
    .PARAMETER verifySslCertificate
    0 or 1. Use 0 when a site is secured with a self-signed certificate. Default is 1.
    .PARAMETER sslVersionId
    [0|1|3] - set to the appropriate value
    .PARAMETER headers
    (array of name/value pairs) (ie, User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0))
    #>
    [CmdletBinding(DefaultParameterSetName = 'NoParam')]
    Param(
        [Parameter(ParameterSetName="NetPing",
                    Mandatory=$true)]
        [switch]$NetPing,

        [Parameter(ParameterSetName="NetPath",
                    Mandatory=$true)]
        [switch]$NetPath,

        [Parameter(ParameterSetName="NetTCP",
                    Mandatory=$true)]
        [switch]$NetTCP,

        [Parameter(ParameterSetName="NetBw",
                    Mandatory=$true)]
        [switch]$NetBW,

        [Parameter(ParameterSetName="WebHttp",
                    Mandatory=$true)]
        [switch]$WebHttp,

        [Parameter(ParameterSetName="WebPage",
                    Mandatory=$true)]
        [switch]$WebPage,

        [Parameter(ParameterSetName="WebTrans",
                    Mandatory=$true)]
        [switch]$WebTrans,

        [Parameter(ParameterSetName="DnsTrace",
                    Mandatory=$true)]
        [switch]$DnsTrace,

        [Parameter(ParameterSetName="DnsServer",
                    Mandatory=$true)]
        [switch]$DnsServer,

        [Parameter(ParameterSetName="DnsServer")]
        [validateset('IN','CH')]
        [string]$queryClass,

        [Parameter(ParameterSetName="DnsServer")]
        [switch]$recursiveQueries,
        
        [Parameter(ParameterSetName="NetPing",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetPath",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetTCP",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetBw",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="WebHttp",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="WebPage",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="WebTrans",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="DnsTrace",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="DnsServer",
                    Mandatory=$true)]
        [int]$agentId,

        [Parameter(ParameterSetName="NetPing",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetPath",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetTCP",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetBw",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="DnsServer",
                    Mandatory=$true)]
        [string]$server,

        [Parameter(ParameterSetName="NetPing")]
        [Parameter(ParameterSetName="NetPath")]
        [Parameter(ParameterSetName="NetTCP",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetBw")]
        [int]$port,

        [Parameter(ParameterSetName="NetPing",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetPath",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="NetBw",
                    Mandatory=$true)]
        [validateset('TCP','ICMP')]
        [string]$pingType,

        [Parameter(ParameterSetName="WebHttp",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="WebPage",
                    Mandatory=$true)]
        [string]$url,

        [Parameter(ParameterSetName="DnsTrace",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="DnsServer",
                    Mandatory=$true)]
        [string]$domain,

        [Parameter(ParameterSetName="DnsTrace",
                    Mandatory=$true)]
        [Parameter(ParameterSetName="DnsServer",
                    Mandatory=$true)]
        [validateset('A','AAAA','ANY','CNAME','DNSKEY','DS','MX','NS','NSE','NULL','PTR','RRSIG','SOA','TXT')]
        [string]$type,

        [Parameter(ParameterSetName="WebTrans",
                    Mandatory=$true)]
        [int]$testId,

        [Parameter(ParameterSetName="WebHttp")]
        [string]$username,

        [Parameter(ParameterSetName="WebHttp")]
        [string]$pw,

        [Parameter(ParameterSetName="WebHttp")]
        [bool]$useNtlm,

        [Parameter(ParameterSetName="WebHttp")]
        [string]$postBody,

        [Parameter(ParameterSetName="WebHttp")]
        [bool]$verifySslCertificate,

        [Parameter(ParameterSetName="WebHttp")]
        [ValidateSet(0,1,3)]
        [int]$sslVersionId,

        [Parameter(ParameterSetName="WebHttp")]
        [string[]]$headers
    )

    Begin{
        if ($PSCmdlet.ParameterSetName -eq 'NoParam') {
            Write-Output "You must select a test type, get-help New-TEApiInstantTest"
            Break
        }
    }

    Process{
        $urlComponents
        $body = @{}
        if ($pingType -eq 'TCP' -and (-not ($port))) {
            $body.port = Read-Host "TCP Port"
        }

        switch ($PSBoundParameters.keys) {
            'NetPing'           {$urlComponents = ('instant', 'net', 'ping')}
            'NetPath'           {$urlComponents = ('instant', 'net', 'path-vis')}
            'NetTCP'            {$urlComponents = ('instant', 'net', 'tcp-connect')}
            'NetBw'             {$urlComponents = ('instant', 'net', 'bandwidth')}
            'WebHttp'           {$urlComponents = ('instant', 'web', 'http-server')}
            'WebPage'           {$urlComponents = ('instant', 'web', 'page-load')}
            'WebTrans'          {$urlComponents = ('instant', 'web', 'transactions')}
            'DnsTrace'          {$urlComponents = ('instant', 'dns', 'trace')}
            'DnsServer'         {$urlComponents = ('instant', 'dns', 'server')}
        }

        switch ($PSBoundParameters.keys) {
            
            'agentId'       { $body.agentId         = $agentId}
            'server'        { $body.server          = $server}
            'port'          { $body.port            = $port}
            'pingType'      { $body.pingType        = $pingType}
            'url'           { $body.url             = $url}
            'domain'        { $body.domain          = $domain}
            'type'          { $body.type            = $type}
            'testId'        { $body.testId          = $testId}
            'username'      { $body.username        = $username}
            'pw'            { $body.password        = $pw}
            'useNtlm'       { $body.useNtlm         = $useNtlm}
            'postBody'      { $body.postBody        = $postBody}
            'verifySslCertificate'  { $body.verifySslCertificate  = $verifySslCertificate}
            'sslVersionId'  { $body.sslVersionId    = $sslVersionId}
            'headers'       { $body.headers         = $headers}
            'queryClass'    { $body.queryClass      = $queryClass}
            'recursiveQueries'      { $body.recursiveQueries    = $true}
        }
        
        $jsonBody = $body | ConvertTo-Json
        $results = Send-TEApi -urlComponents $urlComponents -method post -body $jsonbody
        
        if($results.errorMessage) {
            Write-Output $results.errorMessage
            Break
        }
        switch ($PSBoundParameters.keys) {
            'NetPing'   {Write-Output $results.net.ping}
            'NetPath'   {Write-Output $results.net.pathvis}
            'NetTCP'    {Write-Output $results.net | select tcpConnect}
            'NetBw'     {Write-Output $results.net.metrics}
            'WebHttp'   {Write-Output $results.web.httpServer}
            'WebPage'   {Write-Output $results.web.pageLoad}
            'WebTrans'  {Write-Output $results.web.transaction}
            'DnsServer' {Write-Output $results.dns.server}
            'DnsTrace'  {Write-Output $results.dns.trace}
        }
    }
    End{
        
    }

}