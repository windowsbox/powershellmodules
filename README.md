# PowerShell Modules

Repo for PowerShell modules used to build out new Windows boxes from scratch.

## Modules
- Install Windows Updates
- Configure WinRM
- Set NICs to private
- Disable Hibernate
- Disable AutoLogon
- Disable UAC
- Enable RDP
- Configure Explorer
- Configure Vagrant account
- Compile .NET Assemblies
- Install Choco `iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex`
- Install VM Guest Tools
- Defrag/Compact drive

## Notes

Get PowerShell version: `$PSVersionTable.PSVersion`
Install PowerShell package management preview `choco install powershell-packagemanagement`

## Links
- [Packer-Windows](https://github.com/joefitzgerald/packer-windows)
- [PowerShell Gallery](https://msconfiggallery.cloudapp.net/)
- [How to Write a PowerShell Script Module](https://msdn.microsoft.com/en-us/library/dd878340(v=vs.85).aspx)
- [Building a PowerShell module](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/)
- [PowerShell CD pipeline](http://ramblingcookiemonster.github.io/PSDeploy-Inception/)
- [PackageManagement PowerShell Modules Preview - March 2016](https://www.microsoft.com/en-us/download/details.aspx?id=51451)
