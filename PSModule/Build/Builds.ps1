function Find-Build()
{
  [CmdletBinding()]
  Param(
    [int[]]$Definitions,

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

    [ValidateSet('TfsGit','TfsVersionControl','GitHub','GitHubEnterprise','svn','Git','Bitbucket')]
    [string]$RepositoryType
  )

  Write-Debug ("Definitions: {0}" -f ($Definitions -join ","))
  Write-Debug ("Queues: {0}" -f ($Queues -join ","))
  Write-Debug ("BuildNumber: {0}" -f $BuildNumber)
  Write-Debug ("MinTime: {0}" -f $MinTime)
  Write-Debug ("MaxTime: {0}" -f $MaxTime)
  Write-Debug ("RequestedFor: {0}" -f $RequestedFor)
  Write-Debug ("ReasonFilter: {0}" -f ($ReasonFilter -join ","))
  Write-Debug ("StatusFilter: {0}" -f ($StatusFilter -join ","))
  Write-Debug ("ResultFilter: {0}" -f ($ResultFilter -join ","))
  Write-Debug ("TagFilters: {0}" -f ($TagFilters -join ","))
  Write-Debug ("Properties: {0}" -f ($Properties -join ","))
  Write-Debug ("Top: {0}" -f $Top)
  Write-Debug ("MaxBuildsPerDefinition: {0}" -f $MaxBuildsPerDefinition)
  Write-Debug ("DeletedFilter: {0}" -f ($DeletedFilter -join ","))
  Write-Debug ("QueryOrder: {0}" -f $QueryOrder)
  Write-Debug ("BranchName: {0}" -f $BranchName)
  Write-Debug ("BuildIds: {0}" -f ($BuildIds -join ","))
  Write-Debug ("RepositoryId: {0}" -f $RepositoryId)
  Write-Debug ("RepositoryType: {0}" -f $RepositoryType)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Builds = @{}
  [string]$ContinuationToken = ""

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/build/builds?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project
    
    if($Definitions)            {$Uri += "&definitions=$Definitions"}
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

    $Results = Invoke-WebRequest -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Builds += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return ($Builds | Where {$_.id})
}

function Get-Build()
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('id')]
    [int]$BuildId,

    [string]$PropertyFilters
  )

  Write-Debug ("BuildId: {0}" -f $BuildId)
  Write-Debug ("PropertyFilters: {0}" -f $PropertyFilters)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/build/builds/{3}?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$BuildId

  if($PropertyFilters) {$Uri += "&propertyFilters={0}" -f $PropertyFilters}
  
  Write-Verbose ("Uri: {0}" -f $Uri)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

  Return $Results
}

function Get-BuildLogs()
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('id')]
    [int]$BuildId,

    [ValidateNotNullOrEmpty()]
    [ValidateSet('zip', 'json')]
    [string]$Format = 'json',

    [ValidateNotNullOrEmpty()]
    [string]$OutFile
  )
  
  Write-Debug ("BuildId: {0}" -f $BuildId)
  Write-Debug ("Format: {0}" -f $Format)
  Write-Debug ("OutFile: {0}" -f $OutFile)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/build/builds/{3}/logs?`$format={4}&api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$BuildId,$Format
  
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

function Get-BuildLog()
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true,
               ValueFromPipelineByPropertyName=$true,
               ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('id')]
    [int]$BuildId,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int]$LogId,

    [int]$StartLine,

    [int]$EndLine,

    [ValidateNotNullOrEmpty()]
    [ValidateSet('zip', 'json')]
    [string]$Format = 'json',

    [ValidateNotNullOrEmpty()]
    [string]$OutFile
  )

  Write-Debug ("BuildId: {0}" -f $BuildId)
  Write-Debug ("LogId: {0}" -f $LogId)
  Write-Debug ("StartLine: {0}" -f $StartLine)
  Write-Debug ("EndLine: {0}" -f $EndLine)
  Write-Debug ("Format: {0}" -f $Format)
  Write-Debug ("OutFile: {0}" -f $OutFile)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Results = @()

  [string]$Uri = "{0}/{1}/{2}/_apis/build/builds/{3}/logs/{4}?`$format={5}&api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$BuildId,$LogId,$Format
  
  if($StartLine) {$Uri += "&startLine={0}" -f $StartLine}
  if($EndLine)   {$Uri += "&endLine={0}" -f $EndLine}

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

function Remove-Build()
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