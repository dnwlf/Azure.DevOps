[CmdletBinding()]
Param(
  [ValidateNotNullOrEmpty()]
  [ValidateScript({Test-Path $_})]
  [ValidatePattern("\.psd1$")]
  [string]$Path = ".\PSModule\Azure.DevOps.psd1",

  [ValidateNotNullOrEmpty()]
  [Parameter(Mandatory=$true)]
  [string]$Key
)

#Register-PSRepository -Default
Publish-Module -Name $Path -NuGetApiKey $Key -Repository PSGallery -Force