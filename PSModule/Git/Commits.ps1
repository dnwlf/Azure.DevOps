function Find-CommitBatch {

    [CmdletBinding()]
    Param(
        
        [Parameter(Mandatory = $true)]
        [String] $RepositoryId,

        [int] $Skip,
        [int] $Top,

        [string] $Author,

        [switch] $ExcludeDeletes,

        [string] $FromCommitId,
        [string] $ToCommitId,

        [datetime] $FromDate,
        [datetime] $ToDate,

        [ValidateSet('firstParent', 'fullHistory', 'fullHistorySimplifyMerges', 'simplifiedHistory')]
        [string] $HistoryMode,

        [string[]] $IDs,

        [ValidateSet('branch', 'tag', 'commit')]
        [String] $VersionFilterType,
        [String] $VersionFilter,

        [ValidateSet('branch', 'tag', 'commit')]
        [String] $CompareVersionFilterType,
        [String] $CompareVersionFilter,

        [switch] $IncludeLinks,
        [switch] $IncludeStatuses,
        [switch] $IncludeWorkItems,
        [switch] $IncludePushData,
        [switch] $IncludeUserImageUrl,

        [string] $ItemPath,

        [string] $User

    )

    [psobject] $AzDO = Get-ConnectionInfo

    [string] $Uri = "{0}/{1}/{2}/_apis/git/repositories/{3}/commitsbatch?api-version=5.0" -f $AzDO.BaseUrl, $AzDO.Collection, $AzDO.Project, $RepositoryId
    
    if ($Skip) { $Uri += "&`$skip=$Skip" }
    if ($Top) { $Uri += "&`$top=$Top" }
    if ($IncludeStatuses) { $Uri += "&includeStatuses=$([Xml.XmlConvert]::ToString([Boolean] $IncludeStatuses))" }

    [psobject] $Payload = @{ }
    if ($Author) { $Payload["author"] = $Author }
    if ($User) { $Payload["user"] = $User }
    if ($ExcludeDeletes) { $Payload["excludeDeletes"] = $true }
    
    if ($FromCommitId) { $Payload["fromCommitId"] = $FromCommitId }
    if ($ToCommitId) { $Payload["toCommitId"] = $ToCommitId }
    
    if ($FromDate) { $Payload["fromDate"] = $FromDate.ToString("M/d/yyyy HH:mm:ss") }
    if ($ToDate) { $Payload["toDate"] = $FromDate.ToString("M/d/yyyy HH:mm:ss") }

    if ($HistoryMode) { $Payload["historyMode"] = $HistoryMode }

    if ($IDs) { $Payload["ids"] = $IDs }

    if ($VersionFilter) {
        $Payload["itemVersion"] = @{
            "versionType" = $VersionFilterType
            "version"     = $VersionFilter
        }
    }
    if ($CompareVersionFilter) {
        $Payload["compareVersion"] = @{
            "versionType" = $CompareVersionFilterType
            "version"     = $CompareVersionFilter
        }
    }

    if ($IncludeUserImageUrl) { $Payload["includeUserImageUrl"] = $true }
    if ($IncludeLinks) { $Payload["includeLinks"] = $true }
    if ($IncludePushData) { $Payload["includePushData"] = $true }
    if ($IncludeWorkItems) { $Payload["includeWorkItems"] = $true }

    if ($ItemPath) { $Payload["itemPath"] = $ItemPath }

    Write-Verbose ("Uri: {0}" -f $Uri)
    Write-Verbose $Payload

    $Result = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing -Method Post -Body ($Payload | ConvertTo-Json) -ContentType "application/json"
    Return $Result.value

}