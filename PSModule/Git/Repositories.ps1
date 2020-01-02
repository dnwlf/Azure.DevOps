function Find-Repository {

    [CmdletBinding()]
    Param(
        [Switch] $IncludeLinks,
        [Switch] $IncludeAllUrls,
        [Switch] $IncludeHidden
    )

    [psobject] $AzDO = Get-ConnectionInfo

    [array] $Repos = @( )

    [string] $Uri = "{0}/{1}/{2}/_apis/git/repositories?api-version=5.0" -f $AzDO.BaseUrl, $AzDO.Collection, $AzDO.Project
    
    if ($IncludeLinks) { $Uri += "&includeLinks" }
    if ($IncludeAllUrls) { $Uri += "&includeAllUrls" }
    if ($IncludeHidden) { $Uri += "&includeHidden" }

    Write-Verbose ("Uri: {0}" -f $Uri)

    $Repos = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

    Return $Repos.value
}

function Get-Repository {

    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [Alias("id")]
        [string] $RepositoryId
    )

    [psobject] $AzDO = Get-ConnectionInfo

    [psobject] $Repo = @{ }

    [string] $Uri = "{0}/{1}/{2}/_apis/git/repositories/{3}?api-version=5.0" -f $AzDO.BaseUrl, $AzDO.Collection, $AzDO.Project, $RepositoryId
    
    Write-Verbose ("Uri: {0}" -f $Uri)

    $Repo = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -UseBasicParsing

    Return $Repo

}
