[CmdletBinding()]
Param(
  [ValidateNotNullOrEmpty()]
  [ValidateScript({Test-Path $_})]
  [ValidatePattern("\.psd1$")]
  [string]$Path = "C:\Users\dwolfe\Desktop\Azure.DevOps\PSModule\Azure.DevOps.psd1",

  [ValidateNotNullOrEmpty()]
  [Parameter(Mandatory=$true)]
  [string]$Key
)

#Register-PSRepository -Default

Publish-Module -Name $Path -NuGetApiKey $Key -Repository $PSGallery.Name -Force