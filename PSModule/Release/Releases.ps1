function Find-Release()
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

    [Alias('id')]
    [int]$DefinitionId,

    [int]$DefinitionEnvironmentId,

    [string]$SearchText,

    [string]$CreatedBy,

    [ValidateSet('abandoned','active','draft','undefined')]
    [string[]]$StatusFilter,

    [int]$EnvironmentStatusFilter,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$MinCreatedTime,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$MaxCreatedTime,

    [ValidateSet('ascending','descending')]
    [string]$QueryOrder,

    [int]$Top,

    [ValidateSet('approvals','artifacts','environments','manualInterventions','none','tags','variables')]
    [string[]]$Expand,

    [ValidateSet('Build','Jenkins','GitHub','Nuget','Team Build (external)','ExternalTFSBuild','Git','TFVC','ExternalTfsXamlBuild')]
    [string]$ArtifactTypeId,

    [string]$SourceId,
    
    [string]$ArtifactVersionId,

    [string]$SourceBranchFilter,

    [bool]$IsDeleted,

    [string[]]$TagFilter,

    [string[]]$PropertyFilters,

    [int[]]$ReleaseIdFilter,

    [string]$Path
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject[]]$Releases = @{}
  [string]$ContinuationToken = ""

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/release/releases?api-version=5.0" -f $Url,$Collection,$Project

    if($DefinitionId)            {$Uri += "&definitionId=$DefinitionId"}
    if($DefinitionEnvironmentId) {$Uri += "&definitionEnvironmentId=$DefinitionEnvironmentId"}
    if($SearchText)              {$Uri += "&searchText=$SearchText"}
    if($CreatedBy)               {$Uri += "&createdBy=$CreatedBy"}
    if($StatusFilter)            {$Uri += "&statusFilter={0}" -f ($StatusFilter -join ",")}
    if($EnvironmentStatusFilter) {$Uri += "&environmentStatusFilter=$EnvironmentStatusFilter"}
    if($MinCreatedTime)          {$Uri += "&minCreatedTime=$MinCreatedTime"}
    if($MaxCreatedTime)          {$Uri += "&maxCreatedTime=$MaxCreatedTime"}
    if($QueryOrder)              {$Uri += "&queryOrder=$QueryOrder"}
    if($Top)                     {$Uri += "&`$top=$Top"}
    if($Expand)                  {$Uri += "&`$expand={0}" -f ($Expand -join ",")}
    if($ArtifactTypeId)          {$Uri += "&artifactTypeId=$ArtifactTypeId"}
    if($SourceId)                {$Uri += "&sourceId=$SourceId"}
    if($ArtifactVersionId)       {$Uri += "&artifactVersionId=$ArtifactVersionId"}
    if($SourceBranchFilter)      {$Uri += "&sourceBranchFilter=$SourceBranchFilter"}
    if($IsDeleted)               {$Uri += "&isDeleted={0}" -f $IsDeleted.ToString()}
    if($TagFilter)               {$Uri += "&tagFilter={0}" -f ($TagFilter -join ",")}
    if($PropertyFilters)         {$Uri += "&propertyFilters={0}" -f ($PropertyFilters -join ",")}
    if($ReleaseIdFilter)         {$Uri += "&releaseIdFilter={0}" -f ($ReleaseIdFilter -join ",")}
    if($Path)                    {$Uri += "&path=$Path"}

    if($ContinuationToken)
    {
      $Uri += "&continuationToken={0}" -f $ContinuationToken
    }
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Results = Invoke-WebRequest -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Releases += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return $Releases
}

function Get-Release()
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

    [Alias('id')]
    [int]$ReleaseId,

    [ValidateSet('all','approvalSnapshots','automatedApprovals','manualApprovals','none')]
    [string[]]$ApprovalFilters,

    [string[]]$PropertyFilters,

    [ValidateSet('none','tasks')]
    [string[]]$Expand,

    [int]$TopGateRecords
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject[]]$Releases = @{}

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}?api-version=5.0" -f $Url,$Collection,$Project,$ReleaseId

  if($ApprovalFilters) {$Uri += "&approvalFilters=$ApprovalFilters"}
  if($pPropertyFilters) {$Uri += "&propertyFilters=$PropertyFilters"}
  if($Expand)          {$Uri += "&`$expand={0}" -f ($Expand -join ",")}
  if($TopGateRecords)  {$Uri += "&topGateRecords=$TopGateRecords"}

  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Results
}

function Update-Release()
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
    [int]$ReleaseId,

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ConvertFrom-Json $_})]
    [Parameter(Mandatory=$true)]
    [string]$Body
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}?api-version=5.0-preview" -f $Url,$Collection,$Project,$ReleaseId

  Write-Verbose ("Uri: {0}" -f $Uri)
  Write-Verbose ("Body: {0}" -f $Body)
  
  $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method PUT -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Results
}

function Update-ReleaseResources()
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
    [int]$ReleaseId,

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ConvertFrom-Json $_})]
    [Parameter(Mandatory=$true)]
    [string]$Body
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}?api-version=5.0-preview" -f $Url,$Collection,$Project,$ReleaseId

  Write-Verbose ("Uri: {0}" -f $Uri)
  Write-Verbose ("Body: {0}" -f $Body)
  
  $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method PATCH -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Results
}

function Update-ReleaseEnvironment()
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
    [int]$ReleaseId,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [int]$EnvironmentId,

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ConvertFrom-Json $_})]
    [Parameter(Mandatory=$true)]
    [string]$Body
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}/environments/{4}?api-version=5.0-preview" -f $Url,$Collection,$Project,$ReleaseId,$EnvironmentId

  Write-Verbose ("Uri: {0}" -f $Uri)
  Write-Verbose ("Body: {0}" -f $Body)
  Write-Verbose ("ErrorActionPreference: {0}" -f $ErrorActionPreference)
  
  $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method PATCH -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Results
}