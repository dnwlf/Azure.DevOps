function Set-ConnectionInfo()
{
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$BaseUrl,

    [ValidateNotNullOrEmpty()]
    [string]$Collection,

    [ValidateNotNullOrEmpty()]
    [string]$Project,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [string]$Token
  )

  Write-Debug ("BaseUrl: {0}" -f $BaseUrl)
  Write-Debug ("Collection: {0}" -f $Collection)
  Write-Debug ("Project: {0}" -f $Project)
  Write-Debug ("Token Length: {0}" -f $Token.Length)
  
  [byte[]]$Bytes = [System.Text.Encoding]::UTF8.GetBytes("user:${Token}")

  [psobject]$script:AzDOConnectionInfo = @{
    BaseUrl = $BaseUrl
    Collection = $Collection
    Project = $Project
    Headers = @{Authorization = "Basic {0}" -f [System.Convert]::ToBase64String($Bytes)}
  }
}

function Get-ConnectionInfo()
{
  if(-not $script:AzDOConnectionInfo)
  {
    Throw "Azure DevOps connection info not set. Please run the Set-AzureDevOpsConnectionInfo function to set up connection info."
  }
  else
  {
    Return $script:AzDOConnectionInfo
  }
}

function Clear-ConnectionInfo()
{
  [psobject]$script:AzDOConnectionInfo = @{}
}