function Add-AzureDevOpsBuildFolder()
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

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Path
  )

  Write-Debug ("Url: {0}" -f $Url)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Headers Length: {0}" -f $Headers.Length)
  Write-Debug ("PAT Length: {0}" -f $PAT.Length)
  Write-Debug ("UseDefaultCredentials: {0}" -f $UseDefaultCredentials)

  [psobject]$Headers = Set-AuthorizationHeader -Password $PAT -Headers $Headers

  [string]$Uri = "{0}/{1}/{2}/_apis/build/folders/{3}?api-version=5.0-preview" -f $Url,$Collection,$Project,$Path

  [string]$Body = @{
    path = $Path
    project = $Project
  } | ConvertTo-Json -Depth 100 -Compress

  Write-Verbose ("Uri: {0}" -f $Uri)
  Write-Verbose ("Body: {0}" -f $Body)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method PUT -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseDefaultCredentials:$UseDefaultCredentials -UseBasicParsing

  Return $Results
}