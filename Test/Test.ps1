#Requires -Version 5.1

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

<#
Remove-Module Azure.DevOps -Force -ErrorAction SilentlyContinue
Uninstall-Module Azure.DevOps -AllVersions -Force
#>

Set-Location -Path $PSScriptRoot
Import-Module -Name $PSScriptRoot\..\PSModule\Azure.DevOps.psd1 -Force

$TestData = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName TestParameters.psd1

#Set connection info
Set-AzureDevOpsConnectionInfo -BaseUrl $TestData.Url -Collection $TestData.Collection -Project $TestData.Project -Token $TestData.Token

# /Build/Artifacts
if($false)
{
  [psobject]$Artifact = Find-AzureDevOpsBuildArtifact -BuildId $TestData.BuildId | Where {$_.resource.type -in @('Container')} | Select-Object -First 1
  Get-AzureDevOpsBuildArtifact -BuildId $TestData.BuildId -ArtifactName $Artifact.name -Format zip -OutFile ("{0}\{1}.zip" -f $env:temp,$TestData.BuildId) -Verbose
}

# /Build/Builds
if($false)
{
  [psobject[]]$Builds = Find-AzureDevOpsBuild -Top 1 -MaxBuildsPerDefinition 1
  Get-AzureDevOpsBuild -BuildId $Builds[0].id
}

# /Build/Definitions
if($true)
{
  [psobject[]]$Definitions = Find-AzureDevOpsBuildDefinition
  $Definition = Get-AzureDevOpsBuildDefinition -DefinitionId $Definitions[1].id
  $Result = Update-AzureDevOpsBuildDefinition -DefinitionId $Definitions[1].id -Definition $Definition -Verbose
  $Result
}

#/Build/Folders
if($false)
{
  Add-AzureDevOpsBuildFolder -Path $TestData.TestBuildFolder
}

# /Core/ProjectCollections
if($false)
{
  Get-AzureDevOpsProjects
}

# /Core/Projects
if($false)
{
  Get-AzureDevOpsProjectCollections
}

# /DistributedTask/Pools
if($false)
{
  [psobject[]]$Pools = Get-AzureDevOpsPools
  Get-AzureDevOpsPoolAgent -PoolId $Pools[1].id
}

# /Release/Releases
if($false)
{
  [psobject[]]$Builds = Find-AzureDevOpsBuild -Top 1 -MaxBuildsPerDefinition 1
  Get-AzureDevOpsBuild -BuildId $Builds[0].id
}

# /Release/Definitions
if($true)
{
  [psobject[]]$Definitions = Find-AzureDevOpsReleaseDefinition
  [psobject]$Definition = Get-AzureDevOpsReleaseDefinition -DefinitionId $Definitions[1].id
  $Result = Update-AzureDevOpsReleaseDefinition -DefinitionId $Definitions[1].id -Definition $Definition -Verbose
  $Result
}

# /Tfvc/Changesets
if($false)
{
  [psobject[]]$Changesets = Get-AzureDevOpsTfvcChangesets -ItemPath $TestData.TfvcSourcePath -FromDate $TestData.FromDate -ToDate $TestData.ToDate
  $Changesets | Sort-Object -Property createdDate -Descending
}

Clear-AzureDevOpsConnectionInfo