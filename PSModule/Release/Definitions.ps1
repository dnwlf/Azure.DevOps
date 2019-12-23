function Find-ReleaseDefinition()
{
  [CmdletBinding()]
  Param(
    [string]$SearchText,

    [string]$CreatedBy,

    [ValidateSet('artifacts','environments','lastRelease','none','tags','triggers','variables')]
    [string[]]$Expand,

    [ValidateSet('Build','Jenkins','GitHub','Nuget','Team Build (external)','ExternalTFSBuild','Git','TFVC','ExternalTfsXamlBuild')]
    [string]$ArtifactType,

    [string]$ArtifactSourceId,

    [int]$Top,

    [ValidateSet('idAscending','idDescending','nameAscending','nameDescending')]
    [string]$QueryOrder,

    [string]$Path,

    [bool]$IsExactNameMatch,

    [string[]]$TagFilter,

    [string[]]$PropertyFilters,

    [string[]]$DefinitionIdFilter,

    [bool]$IsDeleted
  )

  Write-Debug ("SearchText: {0}" -f $SearchText)
  Write-Debug ("CreatedBy: {0}" -f $CreatedBy)
  Write-Debug ("Expand: {0}" -f ($Expand -join ","))
  Write-Debug ("ArtifactType: {0}" -f $ArtifactType)
  Write-Debug ("ArtifactSourceId: {0}" -f $ArtifactSourceId)
  Write-Debug ("Top: {0}" -f $Top)
  Write-Debug ("QueryOrder: {0}" -f $QueryOrder)
  Write-Debug ("Path: {0}" -f $Path)
  Write-Debug ("IsExactNameMatch: {0}" -f $IsExactNameMatch)
  Write-Debug ("TagFilter: {0}" -f ($TagFilter -join ","))
  Write-Debug ("PropertyFilters: {0}" -f ($PropertyFilters -join ","))
  Write-Debug ("DefinitionIdFilter: {0}" -f ($DefinitionIdFilter -join ","))
  Write-Debug ("IsDeleted: {0}" -f $IsDeleted)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Definitions = @{}
  [string]$ContinuationToken = ""

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/release/definitions?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project

    if($SearchText)         {$Uri += "&searchText=$SearchText"}
    if($CreatedBy)          {$Uri += "&createdBy=$CreatedBy"}
    if($Expand)             {$Uri += "&`$expand={0}" -f ($Expand -join ",")}
    if($ArtifactType)       {$Uri += "&artifactType=$ArtifactType"}
    if($ArtifactSourceId)   {$Uri += "&artifactSourceId=$ArtifactSourceId"}
    if($Top)                {$Uri += "&`$top=$Top"}
    if($QueryOrder)         {$Uri += "&queryOrder=$QueryOrder"}
    if($Path)               {$Uri += "&path=$Path"}
    if($IsExactNameMatch)   {$Uri += "&isExactNameMatch={0}" -f $IsExactNameMatch.ToString()}
    if($TagFilter)          {$Uri += "&tagFilter={0}" -f ($TagFilter -join ",")}
    if($PropertyFilters)    {$Uri += "&propertyFilters={0}" -f ($PropertyFilters -join ",")}
    if($DefinitionIdFilter) {$Uri += "&definitionIdFilter={0}" -f ($DefinitionIdFilter -join ",")}
    if($IsDeleted)          {$Uri += "&isDeleted={0}" -f $IsDeleted.ToString()}

    if($ContinuationToken)
    {
      $Uri += "&continuationToken={0}" -f $ContinuationToken
    }
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Results = Invoke-WebRequest -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Definitions += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return $Definitions
}

function Get-ReleaseDefinition()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$DefinitionId,

    [string[]]$PropertyFilters
  )

  Write-Debug ("DefinitionId: {0}" -f $DefinitionId)
  Write-Debug ("PropertyFilters: {0}" -f ($PropertyFilters -join ","))

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Definition = @{}

  [string]$Uri = "{0}/{1}/{2}/_apis/release/definitions/{3}?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$DefinitionId

  if($PropertyFilters) {$Uri += "&propertyFilters={0}" -f ($PropertyFilters -join ",")}
    
  Write-Verbose ("Uri: {0}" -f $Uri)

  $Definition = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

  Return $Definition
}

function Update-ReleaseDefinition()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$DefinitionId,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [ValidateScript({ConvertTo-Json $_})]
    [psobject]$Definition
  )

  [string]$Body = $Definition | ConvertTo-Json -Depth 100

  Write-Debug ("DefinitionId: {0}" -f $DefinitionId)
  Write-Debug ("Body: {0}" -f $Body)

  [psobject]$AzDO = Get-ConnectionInfo

  [string]$Uri = "{0}/{1}/{2}/_apis/release/definitions/{3}?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$DefinitionId

  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -Method PUT -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseBasicParsing

  Return $Results
}