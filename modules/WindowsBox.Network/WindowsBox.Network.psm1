<#
.Synopsis
    Configures the network connection
.Description
    This cmdlet configures the net connection interface to be private
#>
function Configure-NetworkConnection {
    # Don't prompt for network location
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

    # Set network connection to private
    $netprofile = Get-NetConnectionProfile
    Set-NetConnectionProfile -InterfaceIndex $netprofile.InterfaceIndex -NetworkCategory Private 
}
