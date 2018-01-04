# PS Gallery publish script to be called from AppVeyor
#

$deploy=$false
$apikey=''

# Setup build environment, needed for BH* env vars
Remove-Item env:BH*
Set-BuildEnvironment

if (($env:BHBranchName -eq 'master') -and ($env:BHCommitMessage -like '*deploy*')) {
  Write-Output "Publishing! On master branch and found keyword 'deploy' in commit message"

  # Ensure we have a PSGallery API key
  if ($null -eq $env:APIKEY) {
    Write-Error '$env:APIKEY must be set before publishing'
    exit 1
  }
  $apikey = $env:APIKEY
  $deploy=$true
} else {
  Write-Output "Skipping publish because not on master branch or commit message doesn't contain the word deploy"
}

# loop over each module
$modules = Get-ChildItem modules
foreach ($m in $modules) {
  # Reset build environment to the current module
  Remove-Item env:BH*
  Set-BuildEnvironment -Path ".\modules\$($m.Name)"

  # Grab the latest published version number from nuget and bump it
  $version = Get-NextNugetPackageVersion -Name $env:BHProjectName
  Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $version

  # Publish the new version if this is a master branch build
  if ($deploy) {
    Write-Output "Publishing $($m.Name) version $version"
    Publish-Module -Path ".\modules\$($m.Name)" -NuGetApiKey $apikey -Verbose
  } else {
    Write-Output "Skipping publish $($m.Name) version $version"
  }
}
