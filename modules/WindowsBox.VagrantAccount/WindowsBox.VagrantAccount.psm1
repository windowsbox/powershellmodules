<#
.Synopsis
    Configures Vagrant account
.Description
    This cmdlet configures the Vagrant user account properties
#>
function Set-VagrantAccount {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions")]
    param()
    
    wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE
}
