function Get-AzureDevOpsPools()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Url,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Collection,

    [psobject]$Headers = @{},

    [string]$PAT,

    [switch]$UseDefaultCredentials
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject[]]$Pools = @{}
  [string]$ContinuationToken = ""

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/_apis/distributedtask/pools?api-version=5.0" -f $Url,$Collection

    if($ContinuationToken)
    {
      $Uri += "&continuationToken={0}" -f $ContinuationToken
    }
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Results = Invoke-WebRequest -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Pools += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return ($Pools | Where {$_.id})
}

function Get-AzureDevOpsPoolAgent()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Url,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Collection,

    [psobject]$Headers = @{},

    [string]$PAT,

    [switch]$UseDefaultCredentials,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$PoolId
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [string]$Uri = "{0}/{1}/_apis/distributedtask/pools/{2}/agents?includeCapabilities=true&includeAssignedRequest=true&api-version=5.0" -f $Url,$Collection,$PoolId

  [psobject]$Agents = Invoke-RestMethod -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Agents.value
}