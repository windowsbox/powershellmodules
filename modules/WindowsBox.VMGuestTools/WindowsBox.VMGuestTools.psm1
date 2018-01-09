<#
.Synopsis
    Install VM Guest Tools
.Description
    This cmdlet installs VM Guest tools for VirtualBox from a mounted CD
#>
function Install-VMGuestTools {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param()
    
    $installed = $false
    foreach ($drive in Get-PSDrive -PSProvider 'FileSystem') {
        $setup = "$($drive.Root)VBoxWindowsAdditions.exe"

        if (Test-Path $setup) {
            ls "$($drive.Root)cert\*.cer" `
                | ForEach { .\VboxCertUtil.exe add-trusted-publisher $_.FullName --root $_.FullName }

            mkdir 'C:\Windows\Temp\virtualbox' -ErrorAction SilentlyContinue
            Start-Process -FilePath $setup -ArgumentList '/S' -WorkingDirectory 'C:\Windows\Temp\virtualbox' -Wait

            Remove-Item C:\Windows\Temp\virtualbox -Recurse -Force
            $installed = $true
        }
    }

    if (!$installed) {
        Write-Error "Guest additions were not installed, did you forget to mount the ISO?"
    }
}
