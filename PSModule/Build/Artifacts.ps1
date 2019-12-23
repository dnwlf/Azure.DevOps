function Find-BuildArtifact()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$BuildId
  )

  Write-Debug ("BuildId: {0}" -f $BuildId)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/build/builds/{3}/artifacts?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$BuildId
  
  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

  Return $Results.value
}

function Get-BuildArtifact()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$BuildId,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$ArtifactName,

    [ValidateNotNullOrEmpty()]
    [ValidateSet('zip', 'json')]
    [string]$Format = 'json',

    [ValidateNotNullOrEmpty()]
    [string]$OutFile
  )

  Write-Debug ("BuildId: {0}" -f $BuildId)
  Write-Debug ("ArtifactName: {0}" -f $ArtifactName)
  Write-Debug ("Format: {0}" -f $Format)
  Write-Debug ("OutFile: {0}" -f $OutFile)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/build/builds/{3}/artifacts?artifactName={4}&`$format={5}&api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$BuildId,$ArtifactName,$Format
  
  Write-Verbose ("Uri: {0}" -f $Uri)

  $IrmParameters = @{
    Uri = $Uri
    Method = "Get"
    Headers = $AzDO.Headers
  }

  if($OutFile)
  {
    $IrmParameters += @{
      OutFile = $OutFile
    }
  }

  $Results = Invoke-RestMethod @IrmParameters

  Return $Results
}

function New-BuildArtifact()
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('id')]
    [int]$BuildId
  )

  Write-Debug ("BuildId: {0}" -f $BuildId)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/build/builds/{3}?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$BuildId
  
  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Method Delete -Headers $AzDO.Headers -UseBasicParsing

  Return $Results
}