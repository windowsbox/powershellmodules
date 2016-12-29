<#
.Synopsis
    Configures Vagrant account
.Description
    This cmdlet configures the Vagrant user account properties
#>
function Set-VagrantAccount {
    wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE
}
