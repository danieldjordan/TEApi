function Edit-TEApiAgent {
    <#
   .SYNOPSIS
   Function for Editing agents
   .DESCRIPTION
   #### STATUS: WORKING ####
   Edits an existing agent
   .EXAMPLE
   Edit-TEApiAgent -id 1111 -enabled
   This will enable an agent with id 1111 

   Edit-TEApiagent -id 1111 -disabled
   .EXAMPLE
   
   .PARAMETER apiVersion
   API version defaults to version 6
   .PARAMETER aid
   Account Group ID
   .PARAMETER id
   Id of agent to change
   .PARAMETER enabled
   switch to enable an agent
   .PARAMETER disabled
    switch to disable an agent
   #>
   param(
       [int]$apiVersion = 6,

       [string]$aid,

       [Parameter(Mandatory=$True,
                  ValueFromPipeline=$true,
                  HelpMessage="agent ID")]
       [string[]]$id,
       [switch]$enable,
       [switch]$disable,
       [string]$inputBody,
       [switch]$commit

   )
   Begin{}
   
       Process{
           if (-not $InputBody){
               $body = @{}
   
               switch ($PSBoundParameters.keys) {
                   'disable'                { $body.enabled               = 0}
                   'enable'                 { $body.enabled               = 1}
               }
           }
           if ($inputBody){
               $body = $inputBody
           }
           $jsonBody = $body | ConvertTo-Json 
           $urlComponentsList = New-Object System.Collections.Generic.List[System.Object]
           $urlComponentsList.add('agents')
           $urlComponentsList.add($id)
           
           $urlComponentsList.add('update')
           $urlComponents = $urlComponentsList.ToArray()
           #Write-Output $urlComponents
           #Write-Output $body

           if ($commit) {
            $results = send-TEApi -method post -urlcomponents $urlComponents -body $jsonBody
            Write-Output $results.agent
           } else {
            Write-Output "To commit following changes to agent $id use the -commit switch"
            Write-Output $jsonbody
           }
       }
       End{}
   }