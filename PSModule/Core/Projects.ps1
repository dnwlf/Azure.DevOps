function Get-Projects()
{
  [CmdletBinding()]
  Param(
    [ValidateSet('all','createPending','deleted','deleting','new','unchanged','wellFormed')]
    [string]$StateFilter,

    [switch]$GetDefaultTeamImageUrl
  )

  Write-Debug ("StateFilter: {0}" -f $StateFilter)
  Write-Debug ("GetDefaultTeamImageUrl: {0}" -f $GetDefaultTeamImageUrl)

  [psobject]$AzDO = Get-ConnectionInfo

  [psobject[]]$Projects = @{}
  [string]$ContinuationToken = ""

  do
  {
    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/_apis/projects?api-version=5.0" -f $AzDO.BaseUrl,$AzDO.Collection

    if($StateFilter)            {$Uri += "&stateFilter={0}" -f $StateFilter}
    if($GetDefaultTeamImageUrl) {$Uri += "&getDefaultTeamImageUrl={0}" -f $GetDefaultTeamImageUrl.ToString()}

    if($ContinuationToken)
    {
      $Uri += "&continuationToken={0}" -f $ContinuationToken
    }
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Results = Invoke-WebRequest -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing
    $ContinuationToken = $Results.Headers.'x-ms-continuationtoken'
    $Projects += ($Results.Content | ConvertFrom-Json).value

  }while($ContinuationToken)

  Return $Projects
}