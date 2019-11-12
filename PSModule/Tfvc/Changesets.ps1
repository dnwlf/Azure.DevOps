function Get-TfvcChangesets()
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

    [string]$Author,

    [string]$ItemPath,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$FromDate,

    [ValidateScript({$_ -as [DateTime]})]
    [string]$ToDate,

    [int]$FromId,

    [int]$ToId,

    [switch]$FollowRenames,

    [switch]$IncludeLinks,

    [switch]$IncludeSourceRename,

    [int]$MaxCommentLength,

    [switch]$IncludeWorkItems,

    [switch]$IncludeDetails,

    [ValidateRange("0","100")]
    [int]$MaxChangeCount,

    [ValidateSet("asc","desc")]
    [string]$OrderBy
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject[]]$Changesets = @{}

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [bool]$Continue = $true
  [int]$Counter = 0
  [int]$Max = 1000

  for($i=0; $i -lt $Max; $i++)
  {
    Write-Debug ("i:{0}" -f $i)

    [psobject[]]$Results = @()

    [string]$Uri = "{0}/{1}/{2}/_apis/tfvc/changesets?api-version=5.0&`$top=100" -f $Url,$Collection,$Project

    if($i -gt 0)            {$Uri += "&`$skip={0}" -f ($i*100)}
    if($Author)             {$Uri += "&searchCriteria.author={0}" -f $Author}
    if($ItemPath)           {$Uri += "&searchCriteria.itemPath={0}" -f $ItemPath}
    if($FromDate)           {$Uri += "&searchCriteria.fromDate={0}" -f $FromDate}
    if($ToDate)             {$Uri += "&searchCriteria.toDate={0}" -f $ToDate}
    if($FromId)             {$Uri += "&searchCriteria.fromId={0}" -f $FromId}
    if($ToId)               {$Uri += "&searchCriteria.toId={0}" -f $ToId}
    if($FollowRenames)      {$Uri += "&searchCriteria.followRenames={0}" -f $FollowRenames}
    if($IncludeLinks)       {$Uri += "&searchCriteria.includeLinks={0}" -f $IncludeLinks}
    if($IncludeSourceRename){$Uri += "&includeSourceRename={0}" -f $IncludeSourceRename}
    if($MaxCommentLength)   {$Uri += "&maxCommentLength={0}" -f $MaxCommentLength}
    if($IncludeWorkItems)   {$Uri += "&includeWorkItems={0}" -f $IncludeWorkItems}
    if($IncludeDetails)     {$Uri += "&includeDetails={0}" -f $IncludeDetails}
    if($MaxChangeCount)     {$Uri += "&maxChangeCount={0}" -f $MaxChangeCount}
    if($OrderBy)            {$Uri += "&`$orderby={0}" -f $OrderBy}

    Write-Verbose ("Uri: {0}" -f $Uri)
    
    $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

    if($Results[0].Count -gt 0)
    {
      $Changesets += $Results[0].Value
    }
    else
    {
      Break
    }
  }

  Return $Changesets
}