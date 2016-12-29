<#
.Synopsis
    Configures AutoLogon
.Description
    This cmdlet configures Windows AutoLogon
#>
function Configure-AutoLogon {
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name AutoAdminLogon -value 0
}
