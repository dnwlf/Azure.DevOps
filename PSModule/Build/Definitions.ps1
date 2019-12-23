function Find-BuildDefinition()
{
  [CmdletBinding()]
  Param(
    [string]$Name,

    [string]$RepositoryId,

    [string]$RepositoryType,

    [ValidateSet('definitionNameAscending','definitionNameDescending','lastModifiedAscending','lastModifiedDescending','none')]
    [string]$QueryOrder,

    [string]$RequestedFor,

    [int]$Top,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$MinMetricsTime,

    [int[]]$DefinitionIds,

    [string]$Path,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$BuiltAfter,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$NotBuiltAfter,

    [bool]$IncludeAllProperties,

    [bool]$IncludeLatestBuilds,

    [string]$TaskIdFilter,

    [int]$ProcessType,

    [string]$YamlFilename
  )

  Write-Debug ("Name: {0}" -f $Name)
  Write-Debug ("RepositoryId: {0}" -f $RepositoryId)
  Write-Debug ("RepositoryType: {0}" -f $RepositoryType)
  Write-Debug ("QueryOrder: {0}" -f $QueryOrder)
  Write-Debug ("RequestedFor: {0}" -f $RequestedFor)
  Write-Debug ("Top: {0}" -f $Top)
  Write-Debug ("MinMetricsTime: {0}" -f $MinMetricsTime)
  Write-Debug ("DefinitionIds: {0}" -f ($DefinitionIds -join ","))
  Write-Debug ("Path: {0}" -f $Path)
  Write-Debug ("BuiltAfter: {0}" -f $BuiltAfter)
  Write-Debug ("NotBuiltAfter: {0}" -f $NotBuiltAfter)
  Write-Debug ("IncludeAllProperties: {0}" -f $IncludeAllProperties)
  Write-Debug ("IncludeLatestBuilds: {0}" -f $IncludeLatestBuilds)
  Write-Debug ("TaskIdFilter: {0}" -f $TaskIdFilter)
  Write-Debug ("ProcessType: {0}" -f $ProcessType)
  Write-Debug ("YamlFilename: {0}" -f $YamlFilename)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Definitions = @{}
  [string]$ContinuationToken = ""

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/build/definitions?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project
    
    if($Name)                 {$Uri += "&name=$Name"}
    if($RepositoryId)         {$Uri += "&repositoryId=$RepositoryId"}
    if($RepositoryType)       {$Uri += "&repositoryType=$RepositoryType"}
    if($QueryOrder)           {$Uri += "&queryOrder=$QueryOrder"}
    if($RequestedFor)         {$Uri += "&requestedFor=$RequestedFor"}
    if($Top)                  {$Uri += "&`$top=$Top"}
    if($MinMetricsTime)       {$Uri += "&minMetricsTime=$MinMetricsTime"}
    if($DefinitionIds)        {$Uri += "&definitionIds={0}" -f ($DefinitionIds -join ",")}
    if($Path)                 {$Uri += "&path=$Path"}
    if($BuiltAfter)           {$Uri += "&builtAfter=$BuiltAfter"}
    if($NotBuiltAfter)        {$Uri += "&notBuiltAfter=$NotBuiltAfter"}
    if($IncludeAllProperties) {$Uri += "&includeAllProperties={0}" -f $IncludeAllProperties.ToString()}
    if($IncludeLatestBuilds)  {$Uri += "&includeLatestBuilds={0}" -f $IncludeLatestBuilds.ToString()}
    if($TaskIdFilter)         {$Uri += "&taskIdFilter=$TaskIdFilter"}
    if($ProcessType)          {$Uri += "&processType=$ProcessType"}
    if($YamlFilename)         {$Uri += "&yamlFilename=$YamlFilename"}

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

function Get-BuildDefinition()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$DefinitionId,

    [string]$Revision,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$MinMetricsTime,

    [string]$PropertyFilters,

    [bool]$IncludeLatestBuilds
  )

  Write-Debug ("DefinitionId: {0}" -f $DefinitionId)
  Write-Debug ("Revision: {0}" -f $Revision)
  Write-Debug ("MinMetricsTime: {0}" -f $MinMetricsTime)
  Write-Debug ("PropertyFilters: {0}" -f $PropertyFilters)
  Write-Debug ("IncludeLatestBuilds: {0}" -f $IncludeLatestBuilds)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject]$Definition = @{}

  [string]$Uri = "{0}/{1}/{2}/_apis/build/definitions/{3}?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$DefinitionId
    
  if($Revision)             {$Uri += "&revision=$Revision"}
  if($MinMetricsTime)       {$Uri += "&minMetricsTime=$MinMetricsTime"}
  if($PropertyFilters)      {$Uri += "&propertyFilters=$PropertyFilters"}
  if($IncludeLatestBuilds)  {$Uri += "&includeLatestBuilds={0}" -f $IncludeLatestBuilds.ToString()}

  Write-Verbose ("Uri: {0}" -f $Uri)

  $Definition = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

  Return $Definition
}

function Update-BuildDefinition()
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
    [psobject]$Definition,

    [int]$secretsSourceDefinitionId,

    [int]$secretsSourceDefinitionRevision
  )

  [string]$Body = $Definition | ConvertTo-Json -Depth 100

  Write-Debug ("DefinitionId: {0}" -f $DefinitionId)
  Write-Debug ("Body: {0}" -f $Body)
  Write-Debug ("secretsSourceDefinitionId: {0}" -f $secretsSourceDefinitionId)
  Write-Debug ("secretsSourceDefinitionRevision: {0}" -f $secretsSourceDefinitionRevision)

  [psobject]$AzDO = Get-ConnectionInfo

  [string]$Uri = "{0}/{1}/{2}/_apis/build/definitions/{3}?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$DefinitionId
    
  if($SecretsSourceDefinitionId)       {$Uri += "&secretsSourceDefinitionId=$SecretsSourceDefinitionId"}
  if($SecretsSourceDefinitionRevision) {$Uri += "&secretsSourceDefinitionRevision=$SecretsSourceDefinitionRevision"}

  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -Method PUT -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseBasicParsing

  Return $Results
}