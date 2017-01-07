# Install nuget to the expected place, but use an older version
# Use version 3.4 because version 3.5 causes nupkg file missing errors when running Publish-Module
$nugetdir = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet'
mkdir $nugetdir
Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/v3.4.4/NuGet.exe' -OutFile "$nugetdir\nuget.exe"

# Install some build tools
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PSScriptAnalyzer
Install-Module -Name BuildHelpers
