# PowerShell Modules
Repo for PowerShell modules used to build new Windows boxes from scratch.

[![Build status](https://ci.appveyor.com/api/projects/status/rrmj9h7y1485qlca/branch/master?svg=true)](https://ci.appveyor.com/project/WindowsBoxAdmin/powershellmodules/branch/master)

## Requirements
- PowerShell V3 or higher.
- Windows 2012R2, 2016, or Windows10.
- PowerShell package management preview or WMF 5 installed.

## Modules
- Install Windows Updates
- Configure WinRM
- Set NICs to private
- Disable Hibernate
- Disable AutoLogon
- Disable UAC
- Enable RDP
- Enable dev mode and install Ubuntu subsystem
- Configure Explorer
- Configure Vagrant account
- Install VM Guest Tools
- Defrag/Compact drive

## Notes

- Get PowerShell version: `$PSVersionTable.PSVersion`
- PSGallery set to trusted: `Set-PSRepository -Name PSGallery -InstallationPolicy Trusted`
- Install module example: `Install-Module -Name 'WindowsBox.WindowsUpdates'`

## Links
- [Packer-Windows](https://github.com/joefitzgerald/packer-windows)
- [PowerShell Gallery](https://msconfiggallery.cloudapp.net/)
- [How to Write a PowerShell Script Module](https://msdn.microsoft.com/en-us/library/dd878340(v=vs.85).aspx)
- [Building a PowerShell module](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)
- [PowerShell CD pipeline](http://ramblingcookiemonster.github.io/PSDeploy-Inception/)
- [PackageManagement PowerShell Modules Preview - March 2016](https://www.microsoft.com/en-us/download/details.aspx?id=51451)
