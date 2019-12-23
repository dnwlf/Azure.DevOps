function Get-ProjectCollections()
{
  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$ProjectCollections = @{}
  [string]$ContinuationToken = ""

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/_apis/projectcollections?api-version=5.0" -f $AzDO.BaseUrl

    if($ContinuationToken)
    {
      $Uri += "&continuationToken={0}" -f $ContinuationToken
    }
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Results = Invoke-WebRequest -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $ProjectCollections += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return $ProjectCollections
}