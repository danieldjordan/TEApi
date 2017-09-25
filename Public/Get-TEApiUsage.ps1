function Get-TEApiUsage{
    <#
    .SYNOPSIS
    Usage Endpoint Getter
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Returns Usage Data for the specified account group, or default group if no account Group specified
    .EXAMPLE
    Get-TEApiUsage
    .EXAMPLE
    Get-TEApiUsage -aid <accountGroupID>
    .PARAMETER apiVersion
    API version defaults to version 6
    .PARAMETER aid
    Account Group ID
    .PARAMETER quota
    Return only Quota data
    .PARAMETER cuUsed
    Return only Cloud Units Used data
    .PARAMETER cuProjected
    Return only Cloud Units Projected data
    .PARAMETER eaUsed
    Return only Enterprise Agents Used data
    .PARAMETER tests
    Return only tests data
    .PARAMETER agents
    Return only Enterprise Agents data
    #>
    [CmdletBinding()]
    param(
        [int]$apiVersion = 6,

        [string]$aid,

        [switch]$quota,

        [switch]$cuUsed,

        [switch]$cuProjected,

        [switch]$eaUsed,

        [switch]$tests,

        [switch]$agents
    )
    BEGIN{}
    PROCESS{
        $usageDetailsObject = Send-TEApi -apiver $apiVersion -urlComponents:@("usage") -aid $aid      
        if ($PSBoundParameters.Count -gt 0){
            switch ($PSBoundParameters.keys) {
                'quota'             {Write-Output $usageDetailsObject.usage | select quota}
                'cuUsed'            {Write-Output $usageDetailsObject.usage | select cloudUnitsUsed}
                'cuProjected'       {Write-Output $usageDetailsObject.usage | select cloudUnitsProjected}
                'eaUsed'            {Write-Output $usageDetailsObject.usage | select enterpriseAgentsUsed}
                'tests'             {Write-Output $usageDetailsObject.usage | select tests}
                'agents'            {Write-Output $usageDetailsObject.usage | select enterpriseAgents}
            }
        }  
        else{
            Write-Output $usageDetailsObject.usage
        }
    }
    END{}
}