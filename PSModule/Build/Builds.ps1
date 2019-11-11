function Find-AzureDevOpsBuild()
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

    [int[]]$Queues,

    [string]$BuildNumber,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$MinTime,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$MaxTime,

    [string]$RequestedFor,

    [ValidateSet('all','batchedCI','buildCompletion','checkInShelveset','individualCI','manual','none','pullRequest','schedule','scheduleForced','triggered','userCreated','validateShelveset')]
    [string[]]$ReasonFilter,

    [ValidateSet('all','cancelling','completed','inProgress','none','notStarted','postponed')]
    [string[]]$StatusFilter,
    
    [ValidateSet('canceled','failed','none','partiallySucceeded','succeeded')]
    [string[]]$ResultFilter,
    
    [string[]]$TagFilters,

    [string[]]$Properties,

    [int]$Top,

    [int]$MaxBuildsPerDefinition,

    [ValidateSet('excludeDeleted','includeDeleted','onlyDeleted')]
    [string[]]$DeletedFilter,

    [ValidateSet('finishTimeAscending','finishTimeDescending','queueTimeAscending','queueTimeDescending','startTimeAscending','startTimeDescending')]
    [string]$QueryOrder,

    [string]$BranchName,

    [int[]]$BuildIds,

    [string]$RepositoryId,

    [string]$RepositoryType
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject[]]$Builds = @{}
  [string]$ContinuationToken = ""

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/build/builds?api-version=5.0" -f $Url,$Collection,$Project
    
    if($Queues)                 {$Uri += "&queues=$Queues"}
    if($BuildNumber)            {$Uri += "&buildNumber=$BuildNumber"}
    if($MinTime)                {$Uri += "&minTime=$MinTime"}
    if($MaxTime)                {$Uri += "&maxTime=$MaxTime"}
    if($RequestedFor)           {$Uri += "&requestedFor=$RequestedFor"}
    if($ReasonFilter)           {$Uri += "&reasonFilter={0}" -f ($ReasonFilter -join ",")}
    if($StatusFilter)           {$Uri += "&statusFilter={0}" -f ($StatusFilter -join ",")}
    if($ResultFilter)           {$Uri += "&resultFilter={0}" -f ($ResultFilter -join ",")}
    if($TagFilters)             {$Uri += "&tagFilters=$TagFilters"}
    if($Properties)             {$Uri += "&properties=$Properties"}
    if($Top)                    {$Uri += "&`$top=$Top"}
    if($MaxBuildsPerDefinition) {$Uri += "&maxBuildsPerDefinition=$MaxBuildsPerDefinition"}
    if($DeletedFilter)          {$Uri += "&deletedFilter={0}" -f ($DeletedFilter -join ",")}
    if($QueryOrder)             {$Uri += "&queryOrder=$QueryOrder"}
    if($BranchName)             {$Uri += "&branchName=$BranchName"}
    if($BuildIds)               {$Uri += "&buildIds=$BuildIds"}
    if($RepositoryId)           {$Uri += "&repositoryId=$RepositoryId"}
    if($RepositoryType)         {$Uri += "&repositoryType=$RepositoryType"}

    if($ContinuationToken)
    {
      $Uri += "&continuationToken={0}" -f $ContinuationToken
    }
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Results = Invoke-WebRequest -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Builds += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return $Builds
}

function Get-AzureDevOpsBuild()
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

    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('id')]
    [int]$BuildId,

    [string]$PropertyFilters
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/build/builds/{3}?api-version=5.0" -f $Url,$Collection,$Project,$BuildId

  if($PropertyFilters) {$Uri += "&propertyFilters={0}" -f $PropertyFilters}
  
  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Results
}