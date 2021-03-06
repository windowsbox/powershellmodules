<#
.Synopsis
    Install Windows Updates
.Description
    This cmdlet installs all available Windows Updates in batches
#>
function Install-WindowsUpdates {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param()
    
    $script:ScriptName = "Install-WindowsUpdates"
    $script:UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
    $script:UpdateSession.ClientApplicationID = 'WindowsBox.WindowsUpdates'
    $script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
    $script:SearchResult = New-Object -ComObject 'Microsoft.Update.UpdateColl'

    $script:Cycles = 0
    $script:CycleUpdateCount = 0
    $script:MaxUpdatesPerCycle=500
    $script:RestartRequired=0
    $script:MoreUpdates=0
    $script:MaxCycles=5

    Get-UpdateBatch
    if ($script:MoreUpdates -eq 1) {
        Install-UpdateBatch
    }
    Invoke-RebootOrComplete
}


function LogWrite {
    Param ([string]$logstring)
    $now = Get-Date -format s
    Add-Content "C:\Windows\Temp\win-updates.log" -value "$now $logstring"
    Write-Output $logstring
}

function Invoke-RebootOrComplete() {
    $RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $RegistryEntry = "InstallWindowsUpdates"
    switch ($script:RestartRequired) {
        0 {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if ($prop) {
                LogWrite "Restart Registry Entry Exists - Removing It"
                Remove-ItemProperty -Path $RegistryKey -Name $RegistryEntry -ErrorAction SilentlyContinue
            }

            LogWrite "No Restart Required"
            Get-UpdateBatch

            if (($script:MoreUpdates -eq 1) -and ($script:Cycles -le $script:MaxCycles)) {
                Install-UpdateBatch
            } elseif ($script:Cycles -gt $script:MaxCycles) {
                LogWrite "Exceeded Cycle Count - Stopping"
            } else {
                LogWrite "Done Installing Windows Updates"
            }
        }
        1 {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if (-not $prop) {
                LogWrite "Restart Registry Entry Does Not Exist - Creating It"
                Set-ItemProperty -Path $RegistryKey -Name $RegistryEntry -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoLogo -ExecutionPolicy Bypass -Command Install-WindowsUpdates"
            } else {
                LogWrite "Restart Registry Entry Exists Already"
            }

            LogWrite "Restart Required - Restarting..."
            Restart-Computer -Force
        }
        default {
            LogWrite "Unsure If A Restart Is Required"
            break
        }
    }
}

function Install-UpdateBatch() {
    $script:Cycles++
    LogWrite "Evaluating Available Updates with limit of $($script:MaxUpdatesPerCycle):"
    $UpdatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    $script:i = 0;
    
    if ($Host.Version.Major -ge 5) {
        $CurrentUpdates = $SearchResult.Updates
    } else {
        $CurrentUpdates = $SearchResult.Updates | Select-Object
    }

    while($script:i -lt $CurrentUpdates.Count -and $script:CycleUpdateCount -lt $script:MaxUpdatesPerCycle) {
        $Update = $CurrentUpdates[$script:i]
        if ($null -eq $Update) {
            LogWrite "> Skipping update number $script:i because it's null"
            Continue
        }
        if (!$Update.IsDownloaded) {
            [bool]$addThisUpdate = $false
            if ($Update.InstallationBehavior.CanRequestUserInput) {
                LogWrite "> Skipping: $($Update.Title) because it requires user input"
            } else {
                if (!($Update.EulaAccepted)) {
                    LogWrite "> Note: $($Update.Title) has a license agreement that must be accepted. Accepting the license."
                    $Update.AcceptEula()
                    [bool]$addThisUpdate = $true
                    $script:CycleUpdateCount++
                } else {
                    [bool]$addThisUpdate = $true
                    $script:CycleUpdateCount++
                }
            }

            if ([bool]$addThisUpdate) {
                LogWrite "Adding: $($Update.Title)"
                $UpdatesToDownload.Add($Update) |Out-Null
            }
        }
        $script:i++
    }

    if ($UpdatesToDownload.Count -eq 0) {
        LogWrite "No Updates To Download..."
    } else {
        LogWrite 'Downloading Updates...'
        $ok = 0;
        while (! $ok) {
            try {
                $Downloader = $UpdateSession.CreateUpdateDownloader()
                $Downloader.Updates = $UpdatesToDownload
                $Downloader.Download()
                $ok = 1;
            } catch {
                LogWrite $_.Exception | Format-List -force
                LogWrite "Error downloading updates. Retrying in 30s."
                $script:attempts = $script:attempts + 1
                Start-Sleep -s 30
            }
        }
    }

    $UpdatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    [bool]$rebootMayBeRequired = $false
    LogWrite 'The following updates are downloaded and ready to be installed:'
    foreach ($Update in $SearchResult.Updates) {
        if (($Update.IsDownloaded)) {
            LogWrite "> $($Update.Title)"
            $UpdatesToInstall.Add($Update) |Out-Null

            if ($Update.InstallationBehavior.RebootBehavior -gt 0){
                [bool]$rebootMayBeRequired = $true
            }
        }
    }

    if ($UpdatesToInstall.Count -eq 0) {
        LogWrite 'No updates available to install...'
        $script:MoreUpdates=0
        $script:RestartRequired=0
        break
    }

    if ($rebootMayBeRequired) {
        LogWrite 'These updates may require a reboot'
        $script:RestartRequired=1
    }

    LogWrite 'Installing updates...'

    $Installer = $script:UpdateSession.CreateUpdateInstaller()
    $Installer.Updates = $UpdatesToInstall
    $InstallationResult = $Installer.Install()
    
    if ($InstallationResult.RebootRequired) {
        $script:RestartRequired=1
    } else {
        $script:RestartRequired=0
    }

    LogWrite "Installation Result: $($InstallationResult.ResultCode)"
    LogWrite "Reboot Required: $($InstallationResult.RebootRequired)"
    LogWrite 'Listing of updates installed and individual installation results:'
    for($i=0; $i -lt $UpdatesToInstall.Count; $i++) {
        LogWrite "> Update: $($UpdatesToInstall.Item($i).Title)"
        LogWrite "> Result: $($InstallationResult.GetUpdateResult($i).ResultCode)"
    }
}

function Get-UpdateBatch() {
    LogWrite "Checking For Windows Updates"
    $Username = $env:USERDOMAIN + "\" + $env:USERNAME

    New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue

    $Message = "Script: $ScriptName`nScript User: $Username `nStarted: " + (Get-Date).toString()

    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
    LogWrite $Message

    $script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
    $script:successful = $FALSE
    $script:attempts = 0
    $script:maxAttempts = 12
    while(-not $script:successful -and $script:attempts -lt $script:maxAttempts) {
        try {
            $script:SearchResult = $script:UpdateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0 and BrowseOnly=0")
            $script:successful = $TRUE
        } catch {
            LogWrite $_.Exception | Format-List -force
            LogWrite "Search call to UpdateSearcher was unsuccessful. Retrying in 10s."
            $script:attempts = $script:attempts + 1
            Start-Sleep -s 10
        }
    }

    if ($SearchResult.Updates.Count -ne 0) {
        $Message = "There are " + $SearchResult.Updates.Count + " more updates."
        LogWrite $Message
        try {
            for($i=0; $i -lt $script:SearchResult.Updates.Count; $i++) {
                LogWrite "> Title: $($script:SearchResult.Updates.Item($i).Title)"
                LogWrite "> Description: $($script:SearchResult.Updates.Item($i).Description)"
                LogWrite "> Reboot Required: $($script:SearchResult.Updates.Item($i).RebootRequired)"
                LogWrite "> EULA Accepted: $($script:SearchResult.Updates.Item($i).EulaAccepted)"
            }
            $script:MoreUpdates=1
        } catch {
            LogWrite $_.Exception | Format-List -force
            LogWrite "Showing SearchResult was unsuccessful. Rebooting."
            $script:RestartRequired=1
            $script:MoreUpdates=0
            Invoke-RebootOrComplete
            LogWrite "Should never happen!"
            Restart-Computer
        }
    } else {
        LogWrite 'There are no applicable updates'
        $script:RestartRequired=0
        $script:MoreUpdates=0
    }
}
