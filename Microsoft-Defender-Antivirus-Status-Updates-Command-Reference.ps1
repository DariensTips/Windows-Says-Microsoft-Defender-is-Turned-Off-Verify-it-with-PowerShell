<#
.SYNOPSIS
    Verify Microsoft Defender Antivirus status and manually update its platform
    and security intelligence using the commands demonstrated in the video.

.DESCRIPTION
    Section-by-section command reference accompanying:
    Windows Says Microsoft Defender Is Turned Off — Verify It with PowerShell

    Includes local and remote status checks, component version identification,
    KB4052623 platform download, SHA-1 comparison, Authenticode inspection,
    security-intelligence download, installation, and post-update verification.

    Open this file in an editor and run selected commands interactively.
    This file is not an unattended installation or remediation script.

.NOTES
    File Name : Microsoft-Defender-Antivirus-Status-Updates-Command-Reference.ps1
    Author    : Darien Hawkins
    Channel   : Darien's Tips
    YouTube   : https://www.youtube.com/@darienstips9409
    GitHub    : https://github.com/DariensTips
    Version   : 1.0
    Created   : 2026-09-20
    Updated   : 2026-09-20
    Source    : DEFAVOFFIX_Title-Script_20260920.txt
    Shell     : Elevated Windows PowerShell
    Applies To: Windows clients and Windows Server with Microsoft Defender
                Antivirus and the Defender PowerShell module available.
                The example update packages are for x64 / amd64 systems.

    REQUIREMENTS
    - Run selected administrative commands in an elevated Windows PowerShell
      session. Use Windows PowerShell 5.1 for this command reference.
    - The remote query requires authorized PowerShell remoting, connectivity,
      and the Defender module on the target computer.
    - The download examples require BitsTransfer, access to the Microsoft
      download endpoints, and an existing writable Downloads directory.
    - Choose an appropriate approved package for the target OS and architecture.

    IMPORTANT
    - A safety stop precedes the examples to prevent whole-file execution.
    - Replace CLIENT-NAME or SERVER-NAME with an authorized target computer.
    - Only Invoke-Command queries the remote system. Downloads and installers
      outside that script block operate on the computer running this session.
    - The platform URL is the fixed 4.18.26080.4 example from the video, not a
      floating latest-version link. Review KB4052623 for a current package.
    - Get-ChildItem selects the newest-modified matching package. Confirm the
      selected file is the intended download before validating or executing it.
    - Hash and signature commands display results; they do not enforce checks.
      Manually compare the hash and require a valid Microsoft signature.
    - SHA-1 is retained for the demonstrated Catalog filename comparison only;
      it is not sufficient proof of publisher identity or protection from attack.
    - Review output before continuing. Do not downgrade a newer platform just
      to reproduce the version shown in the video.

    DISCLAIMER
    Educational and lab reference, provided as-is without warranty. Review each
    command, validate the target and package, test appropriately, and follow
    your organization's security and change-management policies. Not every
    Defender-off notification is false. Status output is not a malware scan.

.LINK
    https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-25h2#4956msgdesc
.LINK
    https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps
.LINK
    https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-updates
.LINK
    https://www.catalog.update.microsoft.com/Search.aspx?q=KB4052623
.LINK
    https://www.microsoft.com/en-us/wdsi/defenderupdates
#>

# SAFETY STOP: Open this file and run only the selected command sections.
# This guard is not part of the commands demonstrated in the video.
throw 'Command reference only. Open this file in an editor and run selected sections in an elevated Windows PowerShell session.'

# =============================================================================
# (B) Verify Defender Antivirus Status with PowerShell - local computer
# =============================================================================
# Review these fields before updating. AMProductVersion is the platform version.
Get-MpComputerStatus |
     Select-Object AntivirusEnabled,
                   RealTimeProtectionEnabled,
                   AMServiceEnabled,
                   AMRunningMode,
                   AntivirusSignatureLastUpdated,
                   AntivirusSignatureVersion,
                   AMEngineVersion,
                   AntivirusSignatureAge,
                   DefenderSignaturesOutOfDate,
                   AMProductVersion

# =============================================================================
# (B) Verify Defender Antivirus Status with PowerShell - remote computer
# =============================================================================
# Replace the example name. This block queries status; it does not install updates.
# $avTargetComputer = "CLIENT-NAME"
$avTargetComputer = "SERVER-NAME"
Invoke-Command -ComputerName $avTargetComputer -ScriptBlock {Get-MpComputerStatus |
     Select-Object AntivirusEnabled,
                   RealTimeProtectionEnabled,
                   AMServiceEnabled,
                   AMRunningMode,
                   AntivirusSignatureLastUpdated,
                   AntivirusSignatureVersion,
                   AMEngineVersion,
                   AntivirusSignatureAge,
                   DefenderSignaturesOutOfDate,
                   AMProductVersion
}

# =============================================================================
# (C) Understand Defender's Version Numbers
# =============================================================================
# AMProductVersion          = Defender Antivirus platform
# AMEngineVersion           = Antimalware engine
# AntivirusSignatureVersion = Security intelligence
Get-MpComputerStatus |
    Select-Object AMProductVersion,
                  AMEngineVersion,
                  AntivirusSignatureVersion,
                  AntivirusSignatureLastUpdated

# =============================================================================
# (D) Manually Update the Defender Antivirus Platform and Security Intelligence
# =============================================================================
# D1. Select and download the platform package.
# The following URL is the exact dated x64 example from the video.
# For ongoing maintenance, replace it with the appropriate current KB4052623
# package URL and revise the version-specific download comment accordingly.
$defenderPlatformDownloadUrl = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/defu/2026/09/updateplatform.amd64fre_314c7bfdd3e57abdf156b40c4f97af62530f63a1.exe"

# Download Microsoft Defender Antivirus platform 4.18.26080.4
Start-BitsTransfer `
    -Source $defenderPlatformDownloadUrl `
    -Destination "$env:USERPROFILE\Downloads\"

# D2. Select the downloaded platform executable and inspect its SHA-1 hash.
# The selection is based on LastWriteTime, not proof of the intended version.
# Confirm the selected path before proceeding. Compare the displayed hash
# manually with the value in the filename obtained from the official Catalog.
$defenderUpdateFullPath = Get-ChildItem `
    "$env:USERPROFILE\Downloads\updateplatform*.exe" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1 -ExpandProperty FullName

Get-FileHash -Algorithm SHA1 $defenderUpdateFullPath

# D3. Inspect the platform executable's Authenticode signature.
# Require Status = Valid and inspect SignerCertificate for the expected Microsoft
# publisher. Stop and investigate if the result is unexpected.
Get-AuthenticodeSignature -FilePath $defenderUpdateFullPath |
    Select-Object Status, StatusMessage, SignerCertificate |
    Format-List

# D4. Download the x64 security-intelligence package.
# This fwlink points to changing package content; the local filename stays fixed.
# Confirm the destination is appropriate and writable before downloading.
$mpamFeDestinationPath = "$env:USERPROFILE\Downloads\mpam-fe.exe"

Start-BitsTransfer `
    -Source 'https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64' `
    -Destination $mpamFeDestinationPath

# D5. Inspect the security-intelligence package's Authenticode signature.
# Require Status = Valid and inspect the expected Microsoft signer before use.
Get-AuthenticodeSignature -FilePath $mpamFeDestinationPath |
    Select-Object Status, StatusMessage, SignerCertificate |
    Format-List

# D6. Install the verified platform package, then the security-intelligence package.
# LOCAL COMPUTER: these commands are not inside the remote Invoke-Command block.
# Continue only after manually reviewing both packages and their signatures.
Start-Process -FilePath $defenderUpdateFullPath -Wait
Start-Process -FilePath $mpamFeDestinationPath -Wait

# =============================================================================
# (E) Verify the Result
# =============================================================================
# Compare protection and version fields with the pre-update output.
# When Defender is the intended primary antivirus, review True protection states
# and AMRunningMode = Normal. The engine version may remain unchanged.
Get-MpComputerStatus |
     Select-Object AntivirusEnabled,
                   RealTimeProtectionEnabled,
                   AMServiceEnabled,
                   AMRunningMode,
                   AntivirusSignatureLastUpdated,
                   AntivirusSignatureVersion,
                   AMEngineVersion,
                   AntivirusSignatureAge,
                   DefenderSignaturesOutOfDate,
                   AMProductVersion

# The video then restarts the computer and revisits Windows Security.
# Perform any restart deliberately, at an appropriate time, and rerun the above
# status check after sign-in. No automatic restart command is added here.
# A single restart without a notification is an observation, not a full security
# health test or proof that an intermittent symptom can never recur.

