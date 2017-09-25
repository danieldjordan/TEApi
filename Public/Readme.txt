Version 1.12
Introduction:
This module is meant to help with Powershell scripting agains the TE API.  It will eventually include all API endpoints.

The module can be used to create more complex scripts, while not having to worry about the API calls

Install Instructions:

The module is published in the powershell gallery and does not have any dependancies at this point

Windows:
You will need to run install-module from an admin powershell terminal

PS> install-module TEApi

You may be prompted to install NuGet provider if you have not used powershell gallery before

You will then be asked if you want to install from an untrusted repository
If it complains about not being able to find the module try
PS> find-module TEApi

OSX:
run an admin powershell session with:
sudo powershell

PS> install-module TEApi

Usage:

You will need to set your authentication with
PS> Set-TEApiConfig

This will need to be done everytime you start a new session, or if you want to change API users

From here you can use the following to get a list of available commands

Get-Command -Module TEApi

individual command help can be seen with get-help <command>
ex. get-help Get-TEApiTest



