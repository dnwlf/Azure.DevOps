# Azure.DevOps
This module provides PowerShell support for Azure DevOps, Azure DevOps Server, and Team Foundation Server APIs. 

# Platform support
Windows 7 through 10 with Windows PowerShell v3 and higher, and PowerShell Core
Linux with PowerShell Core (all PowerShell-supported distributions)
macOS and OS X with PowerShell Core

# Installing the Module
You can install the latest version of the Azure.DevOps module from [PSGallery](https://www.powershellgallery.com)

`Install-Module Azure.DevOps`

# Using the Module
Once installed and imported, set connection info to use any of the other functions contained in the module.

`Set-AzureDevOpsConnectionInfo -BaseUrl <Azure DevOps Instance Url> [-Collection <Organization/Collection Name>] [-Project <Project Name>] -Token <Personal Access Token/OAuth Token>`

This function accepts an Azure DevOps token and sets a script-scoped header variable in memory for use by the other functions in the module.

When done using the module, close your PowerShell session, unload the module, or run the following command in order to clear the Azure DevOps token from memory:

`Clear-AzureDevOpsConnectionInfo`

# Contributing
This extension is in early development. Feel free to help fill out the APIs that haven't been covered yet, or submit issues as you find them.