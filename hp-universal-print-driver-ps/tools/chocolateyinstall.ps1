$ErrorActionPreference = 'Stop'
$toolsDir       = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName    = 'hp-universal-print-driver-ps' 
$url            = 'https://ftp.hp.com/pub/softlib/software13/COL40842/ds-99375-24/upd-ps-x32-7.0.1.24923.exe'
$checksum       = '7BD421A3971AB00E3AB205FF28529D4D9E55556A45F34337962681E62638BECE'
$url64          = 'https://ftp.hp.com/pub/softlib/software13/COL40842/ds-99376-24/upd-ps-x64-7.0.1.24923.exe'
$checksum64     = 'D4A40A474D39C749C55396DCD8BB8E9AA00C7D69AC19A467920DF74DCBC208B6'
$softwareName   = ''
$fileLocation   = "$toolsDir\unzippedfiles\install.exe"

# Make sure Print Spooler service is up and running stolen from cutepdf package.
try {
  $serviceName = 'Spooler'
  $spoolerService = Get-WmiObject -Class Win32_Service -Property StartMode,State -Filter "Name='$serviceName'"
  if ($null -eq $spoolerService) { throw "Service $serviceName was not found" }
  Write-Host "Print Spooler service state: $($spoolerService.StartMode) / $($spoolerService.State)"
  if ($spoolerService.StartMode -ne 'Auto' -or $spoolerService.State -ne 'Running') {
    Set-Service $serviceName -StartupType Automatic -Status Running
    Write-Host 'Print Spooler service new state: Auto / Running'
  }
} catch {
  Write-Warning "Unexpected error while checking Print Spooler service: $($_.Exception.Message)"
}

New-Item $fileLocation -Type directory | Out-Null

$packageArgs = @{
  packageName    = $packageName
  unzipLocation  = "$toolsDir\unzippedfiles"
  fileType       = 'ZIP' 
  url            = $url
  checksum       = $checksum
  checksumType   = 'sha256'
  url64          = $url64
  checksum64     = $checksum64
  checksumType64 = 'sha256'  
}

Install-ChocolateyZipPackage @packageArgs 

$packageArgs = @{
  packageName    = $packageName
  fileType       = 'EXE'
  file           = $fileLocation
  silentArgs     = '/dm /nd /npf /q /h'
  validExitCodes = @(0, 3010, 1641)
  softwareName   = $softwareName
}
 
Install-ChocolateyInstallPackage @packageArgs

Remove-Item "$toolsDir\unzippedfiles" -Recurse | Out-Null
