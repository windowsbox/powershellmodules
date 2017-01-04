# PS Gallery publish script to be called from AppVeyor

# ensure we have a PSGallery API key
if ($null -eq $env:APIKEY) {
  Write-Error '$env:APIKEY must be set before running'
  exit 1
}
$apikey = $env:APIKEY

# loop over each module
$modules = Get-ChildItem modules
foreach ($m in $modules) {
  Set-BuildEnvironment -Path ".\modules\$($m.Name)"

  # Grab the latest published version and bump the metadata
  $version = Get-NextPSGalleryVersion -Name $env:BHProjectName
  Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $version

  # publish the new version if this is a master branch build
  if ($env:appveyor_repo_branch -eq 'master') {
    Write-Output "Publishing $($m.Name) version $version"
    Publish-Module -Path ".\modules\$($m.Name)" -NuGetApiKey $apikey
  } else {
    Write-Output "Skipping publish $($m.Name) version $version because not on master branch and/or not in AppVeyor"
  }
}
