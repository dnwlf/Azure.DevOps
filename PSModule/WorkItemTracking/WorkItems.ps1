function Find-WorkItem {
    
    param(

        [Parameter(Mandatory = $true)]
        [int[]] $IDs,

        [Parameter(Mandatory = $false)]
        [string[]] $Fields,

        [Parameter(Mandatory = $false)]
        [datetime] $AsOf,

        [Parameter(Mandatory = $false)]
        [ValidateSet("all", "fields", "links", "none", "relations")]
        [string] $Expand,

        [Parameter(Mandatory = $false)]
        [ValidateSet("fail", "omit")]
        [string] $ErrorPolicy

    )

    [psobject] $AzDO = Get-ConnectionInfo

    [string] $Uri = "{0}/{1}/{2}/_apis/wit/workitems?api-version=5.0" -f $AzDO.BaseUrl, $AzDO.Collection, $AzDO.Project

    $Uri += "&ids={0}" -f ($IDs -join ",")
    if ($Fields) { $Uri += "&fields={0}" -f ($Fields -join ",") }
    if ($AsOf) { $Uri += "&asOf={0}" -f ($AsOf.ToString()) }
    if ($Expand) { $Uri += "&`expand={0}" -f $Expand }
    if ($ErrorPolicy) { $Uri += "&`errorPolicy={0}" -f $ErrorPolicy }
  
    $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing
    Return $Results.value

}