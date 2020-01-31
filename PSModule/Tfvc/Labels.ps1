function Find-TfvcLabels()
{
  [CmdletBinding()]
  Param(
    #requestData.includeLinks
    [switch]$IncludeLinks, 

    #requestData.maxItemCount
    [int]$MaxItemCount,

    #requestData.itemLabelFilter
    [string]$ItemLabelFilter,

    #requestData.owner
    [string]$Owner,

    #requestData.name
    [string]$Name,

    #requestData.labelScope
    [string]$LabelScope,

    [int]$Top,

    [int]$Skip
  )

  Write-Debug ("IncludeLinks: {0}" -f $IncludeLinks)
  Write-Debug ("MaxItemCount: {0}" -f $MaxItemCount)
  Write-Debug ("ItemLabelFilter: {0}" -f $ItemLabelFilter)
  Write-Debug ("Owner: {0}" -f $Owner)
  Write-Debug ("Name: {0}" -f $Name)
  Write-Debug ("LabelScope: {0}" -f $LabelScope)
  Write-Debug ("Top: {0}" -f $Top)
  Write-Debug ("Skip: {0}" -f $Skip)

  [psobject]$AzDO = Get-ConnectionInfo

  [string]$Uri = "{0}/{1}/{2}/_apis/tfvc/labels?api-version=5.1" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project

  if($IncludeLinks)   {$Uri += "&requestData.includeLinks={0}" -f $IncludeLinks}
  if($MaxItemCount)   {$Uri += "&requestData.maxItemCount={0}" -f $MaxItemCount}
  if($ItemLabelFilter){$Uri += "&requestData.itemLabelFilter={0}" -f $ItemLabelFilter}
  if($Owner)          {$Uri += "&requestData.owner={0}" -f $Owner}
  if($Name)           {$Uri += "&requestData.name={0}" -f $Name}
  if($LabelScope)     {$Uri += "&requestData.labelScope={0}" -f $LabelScope}
  if($Top)            {$Uri += "&`$top={0}" -f $Top}
  if($Skip)           {$Uri += "&`$skip={0}" -f $Skip}

  Write-Verbose ("Uri: {0}" -f $Uri)
    
  [psobject[]]$Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

  Return $Results[0].Value
}