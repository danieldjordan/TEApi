function Backup-TEApiTest {
     <#
    .SYNOPSIS
    Function for backing up ThousandEyes tests
    .DESCRIPTION
    #### STATUS: COMPLETE ####
    Will grab either a single test by using testid or multiple tests by passing an array to testid.  You can also back up all
    tests by using the backupAll switch.  Tests will by default backup to $PWD, this can be changed with TestBackup.  Tests can finally be 
    compressed in a zip file by using the zipFiles switch, the location and name for the zip can also be set with zipSaveLocation and 
    zipfileName respectively.
    .EXAMPLE
    Backup-TEApiTest -testid <testid>
    This will backup a single test with the testid of <testid>
    .EXAMPLE
    Backup-TEApiTest -backupall
    This will backup all tests in the account group
    .EXAMPLE
    Backup-TEApiTest -backupall -zipfiles -zipfilename testbackup.zip -zipSaveLocation c:\backup
    This will backup all tests in the account group and compress them to a file saved at c:\backup\testbackup.zip
    .PARAMETER apiVersion
    API version defaults to version 6
    .PARAMETER aid
    Account Group ID
    .PARAMETER id
    Test ID for Backup
    .PARAMETER backupAll
    switch to backup all tests in the account group
    .PARAMETER zipFiles
    switch to zip returned tests
    .PARAMETER zipfileName
    zip file filename, defaults to dateTime.zip
    .PARAMETER zipSaveLocation
    location to store the zip file, defaults to desktop
    .PARAMETER idSave
    use this switch to save the backup with only the test ID
    #>
    [CmdletBinding()]
    param(
        [int]$apiVersion = 6,

        [string]$aid,

        [Parameter(ParameterSetName="TestBackup",
                   Position=1,
                   Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="Agent ID")]
        [string[]]$id,

        [Parameter(ParameterSetName="TestBackup",
                   HelpMessage="Backup Location")]
        [Parameter(ParameterSetName="BackupAll")]
        [string]$saveLocation = $PWD,

        [Parameter(ParameterSetName="BackupAll",
                   Mandatory=$True,
                   ValueFromPipeline=$true,
                   HelpMessage="Backup All Tests")]
        [switch]$backupAll,

        [Parameter(ParameterSetName="TestBackup",
                   HelpMessage="Zip all XML Files")]
        [Parameter(ParameterSetName="BackupAll")]
        [switch]$zipFiles,

        [Parameter(ParameterSetName="TestBackup",
                   HelpMessage="source file name")]
        [Parameter(ParameterSetName="BackupAll")]
        [string]$zipFilename,

        [Parameter(ParameterSetName="TestBackup",
                   HelpMessage="Location for Zip File")]
        [Parameter(ParameterSetName="BackupAll")]
        [string]$zipSaveLocation = "$HOME\desktop",

        [Parameter(ParameterSetName="TestBackup",
                   HelpMessage="File name as test ID")]
        [Parameter(ParameterSetName="BackupAll")]
        [switch]$idSave
    )
    BEGIN {
        switch ($PSBoundParameters.Keys) {
            'backupAll' {$id = Get-TEApiTest -aid $aid | Select-Object -ExpandProperty testId  }
            'zipFiles'  {$saveLocation = New-Item $ENV:TEMP\TETestBackup -ItemType Directory}
        }
        
        if ($backupAll) {
            $id = Get-TEApiTest -aid $aid | Select-Object -ExpandProperty testId
        }

    }
    PROCESS {
        if ($idSave){
            ForEach ($test in $id) {
                $testSave = $saveLocation + "\$test" + ".xml"
                $testDetailsObject = Send-TEApi $apiVersion -urlComponents:@("tests", "$test") -aid $aid
                $testDetailsObject | Export-Clixml -literalPath $testSave
                $testDetailsObject | Export-Clixml -Path  $testSave
            }
        }
        else {
            ForEach ($test in $id) {
                $testDetailsObject = Send-TEApi $apiVersion -urlComponents:@("tests", "$test") -aid $aid
                $testName = $testDetailsObject.test.testname
                [IO.Path]::GetinvalidFileNameChars() | ForEach-Object {$testName = $testName.Replace($_,' ')}
                $testName = $testName -replace " ", ""
                $testSave = $saveLocation + "\" + $testName.trim() + "-" + $test + ".xml"
                $testDetailsObject | Export-Clixml -literalPath  $testSave
            }
        }
    }
    END { 
        if ($zipFiles) {
            $currentDateTime = Get-Date -format filedate
            if ($zipSaveLocation -eq $saveLocation){
                Write-Output "The zip save location cannot be the same as the backup location"; break
            }

            if (-not $zipfilename) {$zipFileName = "$currentDateTime.zip"}

            $zipSaveLocation = "$zipSaveLocation\$zipfilename"

            if(test-path $zipSaveLocation) {Remove-Item $zipSaveLocation}

            add-type -Assembly "system.io.compression.filesystem"
            [io.compression.zipfile]::createfromdirectory($saveLocation, $zipSaveLocation)
            Remove-Item $ENV:TEMP\TETestBackup -Force -Recurse
            Write-Output "ZIP file saved to:" $zipSaveLocation
        }
    }
}
