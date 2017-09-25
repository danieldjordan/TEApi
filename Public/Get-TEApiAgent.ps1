function Get-TEApiAgent {
     <#
    .SYNOPSIS
    Function for getting agents and BGP Monitors
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Grabs either a list of all agents, details for one or more agents, or a list of BGP monitors
    .EXAMPLE
    Get-TEApiAgent
    This will use the default behavior and return all agents available to the account, both EA and Cloud Agents
    .EXAMPLE
    Get-TEApiTest -id <agentID>
    .PARAMETER apiVersion
    API version defaults to version 6
    .PARAMETER aid
    Account Group ID
    .PARAMETER id
    returns the details for a specific agent
    .PARAMETER bgpMonitors
    returns a list of BGP monitors available on the account
    #>
    [CmdletBinding(DefaultParameterSetName='AgentList')]
    param(
        [int]$apiVersion = 6,

        [string]$aid,

        [Parameter(ParameterSetName="AgentDetails",
                   Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="Agent ID")]
        [string[]]$id,

        [Parameter(ParameterSetName="bgpMonitors",
                   Mandatory=$True,
                   HelpMessage="Bgp Monitor List")]
        [switch]$bgpMonitors,

        [string]$auth
    )
    BEGIN {}
    PROCESS {
        if ($id){
            ForEach ($agent in $id) {
                
                $agentDetailsObject = Send-TEApi $apiVersion -urlComponents:@("agents", "$agent") -aid $aid
                Write-Output $agentDetailsObject.agents
            }
        }
        elseif ($bgpMonitors -eq $true) {
            $agentDetailsObject = Send-TEApi $apiVersion -urlComponents:@("bgp-monitors") -aid $aid
            Write-Output $agentDetailsObject.bgpMonitors
        }
        else {
            $agentListObject = Send-TEApi $apiVersion -urlComponents:@("agents") -aid $aid
            Write-Output $agentListObject.agents
        }
    }
    END {}
}
