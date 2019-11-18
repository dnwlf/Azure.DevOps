function Set-AuthorizationHeader()
{
  [OutputType([psobject])]
  [CmdletBinding()]
  Param(
    [string]$Username,
    [string]$Password,
    [psobject]$Headers = @{}
  )

  if($Password)
  {
    # Username isn't required for PAT
    if(-not $Username){$Username = "user"}
    
    [byte[]]$Bytes = [System.Text.Encoding]::UTF8.GetBytes("${Username}:${Password}")
    [string]$Base64 = "Basic {0}" -f [System.Convert]::ToBase64String($Bytes)

    $Headers.Authorization = $Base64
  }

  Return [psobject]$Headers
}

function Set-AcceptHeader()
{
  [OutputType([psobject])]
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$true)]
    [ValidateSet('application/zip', 'application/json','text/plain')]
    [string]$AcceptType,
    [psobject]$Headers = @{}
  )

  if($AcceptType)
  {
    $Headers.Accept = $AcceptType
  }

  Return [psobject]$Headers
}