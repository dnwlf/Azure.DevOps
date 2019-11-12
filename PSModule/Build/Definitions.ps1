function Find-BuildDefinition()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Url,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Collection,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [psobject]$Headers = @{},

    [string]$PAT,

    [switch]$UseDefaultCredentials,

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

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject[]]$Definitions = @{}
  [string]$ContinuationToken = ""

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/build/definitions?api-version=5.0" -f $Url,$Collection,$Project
    
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

    $Results = Invoke-WebRequest -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing
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
    [string]$Url,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Collection,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [psobject]$Headers = @{},

    [string]$PAT,

    [switch]$UseDefaultCredentials,

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

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Definition = @{}
  [string]$ContinuationToken = ""

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [string]$Uri = "{0}/{1}/{2}/_apis/build/definitions/{3}?api-version=5.0" -f $Url,$Collection,$Project,$DefinitionId
    
  if($Revision)             {$Uri += "&revision=$Revision"}
  if($MinMetricsTime)       {$Uri += "&minMetricsTime=$MinMetricsTime"}
  if($PropertyFilters)      {$Uri += "&propertyFilters=$PropertyFilters"}
  if($IncludeLatestBuilds)  {$Uri += "&includeLatestBuilds={0}" -f $IncludeLatestBuilds.ToString()}

  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-WebRequest -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing
  $Definition = ($Results.Content | ConvertFrom-Json)

  Return $Definition
}

function Update-BuildDefinition()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Url,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Collection,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [psobject]$Headers = @{},

    [string]$PAT,

    [switch]$UseDefaultCredentials,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$DefinitionId,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [psobject]$Definition,

    [int]$secretsSourceDefinitionId,

    [int]$secretsSourceDefinitionRevision
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [string]$Uri = "{0}/{1}/{2}/_apis/build/definitions/{3}?api-version=5.0" -f $Url,$Collection,$Project,$DefinitionId
    
  if($SecretsSourceDefinitionId)       {$Uri += "&secretsSourceDefinitionId=$SecretsSourceDefinitionId"}
  if($SecretsSourceDefinitionRevision) {$Uri += "&secretsSourceDefinitionRevision=$SecretsSourceDefinitionRevision"}

  [string]$Body = $Definition | ConvertTo-Json -Depth 100

  Write-Verbose ("Uri: {0}" -f $Uri)
  Write-Verbose ("Body: {0}" -f $Body)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method PUT -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Results
}