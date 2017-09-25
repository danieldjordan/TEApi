function Edit-TEApiTest {
    <#
   .SYNOPSIS
   Function for Editing agents
   .DESCRIPTION
   #### STATUS: WORKING ####
   Edits an existing agent
   .EXAMPLE
   Edit-TEApiTest -id 1111 -enabled
   This will enable an test with id 1111 
   .EXAMPLE
   
   .PARAMETER apiVersion
   API version defaults to version 6
   .PARAMETER aid
   Account Group ID
   .PARAMETER id
   returns the details for a specific agent
   .PARAMETER enabled
   switch to enable a Test
   .PARAMETER disabled
    switch to disable a Test
   #>
   param(
       [int]$apiVersion = 6,

       [string]$aid,

       [Parameter(Mandatory=$True,
                  ValueFromPipeline=$true,
                  HelpMessage="Test ID")]
       [string[]]$id,
       [switch]$enable,
       [switch]$disable,
       [switch]$commit,
       [array]$agents,
       [int]$timeout,
       [ValidateSet(0,1)]
       [int]$alertsEnabled,
       [ValidateRange(5,60)]
       [int]$httpTimeLimit,
       [ValidateRange(5,60)]
       [int]$pageLoadTimeLimit,
       [ValidateSet(120,300,600,900,1800,3600)]
       [int]$interval

   )
    Begin{}
   
        Process{
            
            $test = Get-TEApiTest -id $id
            $testType = $test.type
            
            if (-not $InputBody){

                # if Agent array passed iterate through the agents and create an agents array with agent Id label
                if($agents){
                    $subagents = @() # Creating an empty Array for the foreach block
                    foreach($agent in $agents){
                        $subagents += [PSCustomObject]@{
                            'agentId' = "$agent"}
                    }
                    
                }
                # Add the arrays to the body boject
                if ($subagents) {
                    $body = [pscustomobject]@{
                        agents = $subagents
                    }
                } else {
                    $body = @{}
                }

                        
                # switch to add all optional parameters to the body for conversion into JSON
                switch ($PSBoundParameters.keys) {
                    'disable'                { $body | Add-Member -name "enabled" -value "0" -MemberType NoteProperty}
                    'enable'                 { $body | Add-Member -name "enabled" -value "1" -MemberType NoteProperty}
                    'timeout'                { $body | Add-Member -name "timeout" -value "$timeout" -MemberType NoteProperty}
                    'alertsEnabled'          { $body | Add-Member -name "alertsEnabled" -value "$alertsEnabled" -MemberType NoteProperty}
                    'httpTimeLimit'          { $body | Add-Member -name "httpTimeLimit" -value "$httpTimeLimit" -MemberType NoteProperty}
                    'pageLoadTimeLimit'      { $body | Add-Member -name "pageLoadTimeLimit" -value "$pageLoadTimeLimit" -MemberType NoteProperty}
                    'interval'               { $body | Add-Member -name "interval" -value "$interval" -MemberType NoteProperty}
                } 
            }  

            # Convert the body object into a json object
            $jsonBody = $body | ConvertTo-Json 

            # Build urlComponentList to pass to send-teapi
            $urlComponentsList = New-Object System.Collections.Generic.List[System.Object]
            $urlComponentsList.add('tests')
            $urlComponentsList.add($testType)
            $urlComponentsList.add($id)
            $urlComponentsList.add('update')
            $urlComponents = $urlComponentsList.ToArray()

            # If user includes commit switch process the test edit, otherwise prompt for confirmation
            if ($commit) {
                send-TEApi -method post -urlcomponents $urlComponents -body $jsonBody | Out-Null
            } else {
                Write-Output "To commit following changes to agent $id use the -commit switch."
                Write-Output $jsonbody
            }
        }
       End{}
   }