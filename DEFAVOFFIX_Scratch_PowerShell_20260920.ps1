#################################################################
# (B) Verify Defender Antivirus Status with PowerShell
#################################################################

# Check the status of Microsoft Defender Antivirus on the local computer
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

# Check the status of Microsoft Defender Antivirus on a remote computer
$avTargetComputer = "dc25core"
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


#################################################################
# (C) Understand Defender's Version Numbers
#################################################################

# Check the version numbers of Microsoft Defender Antivirus on the local computer
Get-MpComputerStatus |
    Select-Object AMProductVersion,
                  AMEngineVersion,
                  AntivirusSignatureVersion,
                  AntivirusSignatureLastUpdated


#################################################################
# (D) Manually Update the Defender Antivirus Platform and Security Intelligence
#################################################################

$defenderPlatformDownloadUrl = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/defu/2026/09/updateplatform.amd64fre_314c7bfdd3e57abdf156b40c4f97af62530f63a1.exe"
# Download Microsoft Defender Antivirus platform 4.18.26080.4
Start-BitsTransfer `
    -Source $defenderPlatformDownloadUrl `
    -Destination "$env:USERPROFILE\Downloads\"

# Get the full path of the downloaded Microsoft Defender Antivirus platform update and assing to a variable
$defenderUpdateFullPath = Get-ChildItem `
    "$env:USERPROFILE\Downloads\updateplatform*.exe" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1 -ExpandProperty FullName

# Check the SHA1 hash of the downloaded Microsoft Defender Antivirus platform update
Get-FileHash -Algorithm SHA1 $defenderUpdateFullPath

# Check the digital signature of the downloaded Microsoft Defender Antivirus platform update
Get-AuthenticodeSignature -FilePath $defenderUpdateFullPath |
    Select-Object Status, StatusMessage, SignerCertificate |
    Format-List


$mpamFeDestinationPath = "$env:USERPROFILE\Downloads\mpam-fe.exe"
# Download the latest Microsoft Defender Antivirus security intelligence package
Start-BitsTransfer `
    -Source 'https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64' `
    -Destination $mpamFeDestinationPath

# Check the digital signature of the downloaded security intelligence package
Get-AuthenticodeSignature -FilePath $mpamFeDestinationPath |
    Select-Object Status, StatusMessage, SignerCertificate |
    Format-List

# Run the Microsoft Defender Antivirus platform update and the security intelligence package update
Start-Process -FilePath $defenderUpdateFullPath -Wait
Start-Process -FilePath $mpamFeDestinationPath -Wait


#################################################################
# (E) Verify the Result
#################################################################

# Check the status of Microsoft Defender Antivirus on the local computer
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