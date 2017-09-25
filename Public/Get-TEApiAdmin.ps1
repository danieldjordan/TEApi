function Get-TEApiAdmin {
     <#
    .SYNOPSIS
    Admin Endpoint Getter
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Returns either a list of all account Groups, users, roles or permissions.
    Can also return details for a specific Account Group, user, or role, defaults to account groups
    .EXAMPLE
    Get-TEApiAdmin -roles
    Returns a list of all roles in the account Group
    .EXAMPLE
    Get-TEApiAdmin -users
    Returns a list of all users in the account Group
    .EXAMPLE
    Get-TEApiAdmin -userId <userId>
    Returns details for user <userId>
    .PARAMETER apiVersion
    API version defaults to version 6
    .PARAMETER accountGroups
    switch to return all account groups
    .PARAMETER users
    switch to return all users
    .PARAMETER roles
    switch to return all roles
    .PARAMETER aid
    Account Group ID
    .PARAMETER accountGroupId
    account group id for account group details
    .PARAMETER userId
    user ID for user details
    .PARAMETER roleId
    role ID for role details
    .PARAMETER permissions
    switch to return all permissions
    #>
    [CmdletBinding(DefaultParameterSetName='accountGroups')]
    param(
        [int]$apiVersion = 6,

        [Parameter(ParameterSetName="accountGroups")]
        [Parameter(ParameterSetName="roles")]
        [Parameter(ParameterSetName="accountGroupsDetails")]
        [Parameter(ParameterSetName="userDetails")]
        [Parameter(ParameterSetName="rolesDetails")]
        [Parameter(ParameterSetName="permissions")]
        [string]$aid,
        
        [Parameter(ParameterSetName="accountGroups")]
        [switch]$accountGroups,

        [Parameter(ParameterSetName="users",
                    Mandatory=$true)]
        [switch]$users,

        [Parameter(ParameterSetName="roles",
                    Mandatory=$true)]
        [switch]$roles,

        [Parameter(ParameterSetName="accountGroupsDetails",
                    Mandatory=$true)]
        [string]$accountGroupId,

        [Parameter(ParameterSetName="userDetails",
                    ValueFromPipeline = $true,
                    Mandatory=$true)]
        [string]$userId,

        [Parameter(ParameterSetName="rolesDetails",
                    ValueFromPipeline = $true,
                    Mandatory=$true)]
        [string]$roleId,

        [Parameter(ParameterSetName="permissions",
                    Mandatory=$true)]
        [switch]$permissions


    )
    BEGIN {}
    PROCESS {
        
        $urlComponentsList = New-Object System.Collections.Generic.List[System.Object]
        if ($PSBoundParameters.Count -eq 0){
            $PSBoundParameters.Add('accountGroups',$true)
        }
        switch ($PSBoundParameters.keys) {
            'accountGroups'                 { $urlComponentsList.add('account-groups')}
            'accountGroupId'                { $urlComponentsList.add('account-groups')
                                              $urlComponentsList.add($accountGroupId)}
            'users'                         { $urlComponentsList.add('users')}
            'userId'                        { $urlComponentsList.add('users');
                                                $urlComponentsList.add($userId)}
            'roles'                         { $urlComponentsList.add('roles')}
            'roleId'                        { $urlComponentsList.add('roles');
                                                $urlComponentsList.add($roleId)}
            'permissions'                   { $urlComponentsList.add('permissions')}      
        }

        $urlComponents = $urlComponentsList.ToArray()
        $results = send-TEApi -urlComponents $urlComponents -aid $aid
       
        switch ($PSBoundParameters.keys) {
            'accountGroups'                 { Write-Output $results.accountGroups}
            'accountGroupsDetails'          { Write-Output $results.accountGroups}
            'users'                         { Write-Output $results.users}
            'userId'                        { Write-Output $results.users}
            'roles'                         { Write-Output $results.roles}
            'roleId'                        { Write-Output $results.roles}
            'permissions'                   { Write-Output $results.permissions}
            default                         { Write-Output $results.accountGroups}
        }
    }
    END {}
}