The Beauty of a Rest based API is that it can be scripted against with your favorite scripting/programming language. Today's post will cover a ThousandEyes PowerShell module that you can use to access the ThousandEyes API.

### What is PowerShell

We obviously don't have time to cover everything that is PowerShell but for some more detailed information check out Microsoft's PowerShell page at [msdn](https://msdn.microsoft.com/en-us/powershell/mt173057.aspx):

> ## What is PowerShell?
> 
> PowerShell is an automation platform and scripting language for Windows and Windows Server that allows you to simplify the management of your systems. Unlike other text-based shells, PowerShell harnesses the power of the .NET Framework, providing rich objects and a massive set of built-in functionality for taking control of your Windows environments.

If you are on Windows OS, and it is at least version 7 then you already have Powershell installed, and now Microsoft has released PowerShell as an open source project so you can also get it on Linux and macOS. Though it was developed to handle windows OS tasks it has evolved to do much more. Specifically what we will cover today is it's ability to make API calls and manipulate the data that it gets back from those calls.

### Getting Started

For Windows users you already have PS installed and can be accessed by typing powershell into your windows search. For Linux and macOS users check out the [PowerShell Github Repository](https://github.com/PowerShell/PowerShell) which includes instructions on how to download and install PowerShell.

For this walkthrough I do not assume any prior experience with PowerShell, though for those PowerShell gurus out there you can probably skip the rest of this section.

#### Prerequisites

The ThousandEyes PowerShell module was written and tested using version 5.1 of PowerShell. Other versions should work, but they have not been tested against. Being the new kid on the block I did do some testing against version 6 which is what you will get if you are installing on Linux or macOS, but as it is open source and new there is some functionality that does not seem to work perfectly yet so I have tried to write the module to take that into consideration.

You will also need a ThousandEyes username and API token which you can get from your profile settings page [here](https://app.thousandeyes.com/settings/account/?section=profile). If you do not have a ThousandEyes account you can sign up for a free trial account at [https://www.thousandeyes.com/signup](https://www.thousandeyes.com/signup).

#### Installing modules from PowerShell Gallery

If you have never used it, the PowerShell gallery is a Microsoft hosted repository where scripts and modules can be uploaded for sharing to the PowerShell community. If you have version 5 of PS then you already have the PowerShellGet module installed. If you are on a previous version you will need to download it from [here](https://msdn.microsoft.com/powershell/reference/5.1/PowerShellGet/PowerShellGet). The PowerShellGet module also uses the NuGet package manager which you may be prompted to install when you use the next command.

#### Searching the PowerShell Gallery

You can search the PS Gallery by using the find-module cmdlet.



    #Search the PowerShell Gallery for the TEApi module
    Find-Module TEApi
    
    #This will return the following
    Version Name Repository Description
    ------- ---- ---------- -----------
    1.141 TEApi PSGallery A helper Module for the ThousandEyes API


#### Installing the TEApi Module

Using an Elevated PowerShell install the TEApi module with the following commands:

    # Install the TEApi module from the PowerShell Gallery
    Install-Module TEApi

You will be prompted to accept that you are installing a module from an untrusted repository, enter **y** to continue. If you are concerned with what you are downloading, the full source code is available at the TEApi PowerShell gallery page: [www.powershellgallery.com/packages/TEApi/](http://www.powershellgallery.com/packages/TEApi/).

#### Importing the TEApi Module

The TEApi module will automatically be imported anytime you use one of the functions in the module. So using the Set-TEApiConfig command in the next section will automatically import the module into your current session.

You can also import the function manually with:

    #Manually Import the Module into your PowerShell Session
    Import-Module -name TEApi

#### Setting up your ThousandEyes Authentication

The first step after getting the module installed is to set your ThousandEyes API authentication. This will allow you to use all the functions without having to enter your username and API Token every time you make an API call. To set your AuthToken for the session use the following function:

    #Sets the Authentication to use for TEApi functions
    Set-TEApiConfig

This will prompt you for your username and API token. This function also takes optional parameters which you can see by using:


    #Gets Help for any function
    Get-Help Set-TEApiConfig

    #Gets examples for using a function
    Get-Help Set-TEApiConfig -examples


This function by default will only save the Username and API token for the current session. If you would like to have the API token stored locally you can use the optional -saveAuth option on the function. This will be default save the username and API token to the Desktop, which can also be changed with the -saveLocation option. If you are using version 5 of PS then the file will be stored encrypted. If you are on the newer opensource version 6, then it will be saved as plain text.

If you would like to check the auth that is currently in use you can use the -currentAuth option, which will return the username the scripts are currently using.

Also, like many of the functions in the module you can pass the variables in to the function, so if you do not want to be prompted for the username or api Token you can run it as follows:


    #Sets current Authentication parameters and saves to file on the Desktop
    Set-TEApiConfig -teUserName &amp;lt;UserName&amp;gt; -apiToken &amp;lt;Enter API Token here&amp;gt; -saveAuth


Now you are all set to start using the rest of the functions available as part of the module.

### Using the TEApi Module

Now that the module is installed and you have set you Authentication information you can start using the functions. To get a list of the currently available functions in the module use the following command:

    #Gets the functions available in the TEApi module
    Get-Command -module TEApi

Also, each function has built in help that you can use to grab the parameters the function will accept as well as examples of the usage.


    #Displays the basic help for function
    Get-Help -name Set-TEApiConfig
    
    #Displays usage examples
    Get-Help -name Set-TEApiConfig -Examples

You should now have enough to check out the available functions as well as try a few out. The next Blog post will walk through some examples including using some of the built in PS functionality to do some cool stuff with the data we get back from the API
