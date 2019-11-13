#Requires -Version 5.1

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

<#
Remove-Module Azure.DevOps -Force -ErrorAction SilentlyContinue
Uninstall-Module Azure.DevOps -AllVersions -Force
#>

$TestData = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName TestParameters.psd1

Set-Location -Path $PSScriptRoot
Import-Module -Name $PSScriptRoot\..\PSModule\Azure.DevOps.psd1 -Force

if($true)
{
  [psobject[]]$Changesets = Get-AzureDevOpsTfvcChangesets -Url $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -PAT $TestData.PAT -ItemPath $TestData.TfvcSourcePath -FromDate $TestData.FromDate -ToDate $TestData.ToDate
  $Changesets | Sort-Object -Property createdDate -Descending
}

if($false)
{
  [psobject[]]$Builds = Find-AzureDevOpsBuild -Url $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -UseDefaultCredentials -Top 1
  Get-AzureDevOpsBuild -BuildId $Builds[0].id -Url $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -UseDefaultCredentials
}

if($false)
{
  [psobject[]]$Pools = Get-AzureDevOpsPools -Url $TestData.Url -Collection $TestData.Collection -UseDefaultCredentials
  Get-AzureDevOpsPoolAgent -Url $TestData.Url -Collection $TestData.Collection -UseDefaultCredentials -PoolId $Pools[0].id
}

if($false)
{
  [psobject[]]$Definitions = Find-AzureDevOpsBuildDefinition -Url $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -UseDefaultCredentials
  $Definition = Get-AzureDevOpsBuildDefinition -Url $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -UseDefaultCredentials -DefinitionId $Definitions[1].id
  $Result = Update-AzureDevOpsBuildDefinition -Url $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -UseDefaultCredentials -DefinitionId $Definitions[1].id -Definition $Definition -Verbose
  $Result
}

if($false)
{
  Add-AzureDevOpsBuildFolder -Url $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -UseDefaultCredentials -Path "\Test123"
}