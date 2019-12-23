function Add-BuildFolder()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Path
  )

  Write-Debug ("Path: {0}" -f $Path)

  [psobject]$AzDO = Get-ConnectionInfo

  [string]$Uri = "{0}/{1}/{2}/_apis/build/folders/{3}?api-version=5.0-preview" -f $AzDO.BaseUrl,$AzDO.Collection,$AzDO.Project,$Path

  [string]$Body = @{
    path = $Path
    project = $Project
  } | ConvertTo-Json -Depth 100 -Compress

  Write-Verbose ("Uri: {0}" -f $Uri)
  Write-Verbose ("Body: {0}" -f $Body)

  $Results = Invoke-RestMethod -Uri $Uri -Headers $AzDO.Headers -Method PUT -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($Body)) -UseBasicParsing

  Return $Results
}