<#
.Synopsis
    Configures RDP
.Description
    This cmdlet configures Windows RDP
#>
function Enable-RDP {
    # Enable RDP
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Type DWord -Value 0

    # Disable Network Level Authentication
    $netauth = Get-WmiObject -Class Win32_TSGeneralSetting -ComputerName "." -Namespace root\CIMV2\TerminalServices -Authentication PacketPrivacy
    $netauth.SetUserAuthenticationRequired(0)
    
    # Enable RDP on the firewall
    Enable-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-in)'
}
