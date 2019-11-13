function Find-ReleaseDefinition()
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

    [string]$Uri = "{0}/{1}/{2}/_apis/release/definitions?api-version=5.0" -f $Url,$Collection,$Project

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

    $Results = Invoke-WebRequest -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Definitions += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return $Definitions
}