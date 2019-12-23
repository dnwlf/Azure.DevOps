function Get-Pools()
{
  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Pools = @{}
  [string]$ContinuationToken = ""

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/_apis/distributedtask/pools?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection

    if($ContinuationToken)
    {
      $Uri += "&continuationToken={0}" -f $ContinuationToken
    }
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Results = Invoke-WebRequest -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Pools += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return ($Pools | Where {$_.id})
}

function Get-PoolAgent()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [Alias('id')]
    [int]$PoolId
  )

  Write-Debug ("PoolId: {0}" -f $PoolId)

  [psobject]$AzDO = Get-ConnectionInfo

  [string]$Uri = "{0}/{1}/_apis/distributedtask/pools/{2}/agents?includeCapabilities=true&includeAssignedRequest=true&api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection,$PoolId

  [psobject]$Agents = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

  Return $Agents.value
}