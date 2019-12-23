function Find-Release()
{
  [CmdletBinding()]
  Param(
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

  Write-Debug ("DefinitionId: {0}" -f $DefinitionId)
  Write-Debug ("DefinitionEnvironmentId: {0}" -f $DefinitionEnvironmentId)
  Write-Debug ("SearchText: {0}" -f $SearchText)
  Write-Debug ("CreatedBy: {0}" -f $CreatedBy)
  Write-Debug ("StatusFilter: {0}" -f ($StatusFilter -join ","))
  Write-Debug ("EnvironmentStatusFilter: {0}" -f $EnvironmentStatusFilter)
  Write-Debug ("MinCreatedTime: {0}" -f $MinCreatedTime)
  Write-Debug ("MaxCreatedTime: {0}" -f $MaxCreatedTime)
  Write-Debug ("QueryOrder: {0}" -f $QueryOrder)
  Write-Debug ("Top: {0}" -f $Top)
  Write-Debug ("Expand: {0}" -f ($Expand -join ","))
  Write-Debug ("ArtifactTypeId: {0}" -f $ArtifactTypeId)
  Write-Debug ("SourceId: {0}" -f $SourceId)
  Write-Debug ("ArtifactVersionId: {0}" -f $ArtifactVersionId)
  Write-Debug ("SourceBranchFilter: {0}" -f $SourceBranchFilter)
  Write-Debug ("IsDeleted: {0}" -f $IsDeleted)
  Write-Debug ("TagFilter: {0}" -f ($TagFilter -join ","))
  Write-Debug ("PropertyFilters: {0}" -f ($PropertyFilters -join ","))
  Write-Debug ("ReleaseIdFilter: {0}" -f ($ReleaseIdFilter -join ","))
  Write-Debug ("Path: {0}" -f $Path)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Releases = @{}
  [string]$ContinuationToken = ""

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/release/releases?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project

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

    $Results = Invoke-WebRequest -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Releases += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return $Releases
}

function Get-Release()
{
  [CmdletBinding()]
  Param(
    [Alias('id')]
    [int]$ReleaseId,

    [ValidateSet('all','approvalSnapshots','automatedApprovals','manualApprovals','none')]
    [string[]]$ApprovalFilters,

    [string[]]$PropertyFilters,

    [ValidateSet('none','tasks')]
    [string[]]$Expand,

    [int]$TopGateRecords
  )

  Write-Debug ("ReleaseId: {0}" -f $ReleaseId)
  Write-Debug ("ApprovalFilters: {0}" -f ($ApprovalFilters -join ","))
  Write-Debug ("PropertyFilters: {0}" -f ($PropertyFilters -join ","))
  Write-Debug ("Expand: {0}" -f ($Expand -join ","))
  Write-Debug ("TopGateRecords: {0}" -f $TopGateRecords)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Releases = @{}

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$ReleaseId

  if($ApprovalFilters)  {$Uri += "&approvalFilters=$ApprovalFilters"}
  if($pPropertyFilters) {$Uri += "&propertyFilters=$PropertyFilters"}
  if($Expand)           {$Uri += "&`$expand={0}" -f ($Expand -join ",")}
  if($TopGateRecords)   {$Uri += "&topGateRecords=$TopGateRecords"}

  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

  Return $Results
}

function Update-Release()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [int]$ReleaseId,

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ConvertFrom-Json $_})]
    [Parameter(Mandatory=$true)]
    [string]$Body
  )

  Write-Debug ("ReleaseId: {0}" -f $ReleaseId)
  Write-Debug ("Body: {0}" -f $Body)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}?api-version=5.0-preview" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$ReleaseId

  Write-Verbose ("Uri: {0}" -f $Uri)
  
  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -Method PUT -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseBasicParsing

  Return $Results
}

function Update-ReleaseResources()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [int]$ReleaseId,

    [ValidateNotNullOrEmpty()]
    [ValidateScript({ConvertFrom-Json $_})]
    [Parameter(Mandatory=$true)]
    [string]$Body
  )

  Write-Debug ("ReleaseId: {0}" -f $ReleaseId)
  Write-Debug ("Body: {0}" -f $Body)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}?api-version=5.0-preview" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$ReleaseId

  Write-Verbose ("Uri: {0}" -f $Uri)
  
  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -Method PATCH -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseBasicParsing

  Return $Results
}

function Update-ReleaseEnvironment()
{
  [CmdletBinding()]
  Param(
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

  Write-Debug ("ReleaseId: {0}" -f $ReleaseId)
  Write-Debug ("EnvironmentId: {0}" -f $EnvironmentId)
  Write-Debug ("Body: {0}" -f $Body)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/release/releases/{3}/environments/{4}?api-version=5.0-preview" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$ReleaseId,$EnvironmentId

  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -Method PATCH -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseBasicParsing

  Return $Results
}