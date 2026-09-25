# Windows Says Microsoft Defender Is Turned Off — Verify It with PowerShell

PowerShell command reference for verifying Microsoft Defender Antivirus status, distinguishing its component versions, and manually updating the Defender Antivirus platform and security intelligence.

**Author:** Darien Hawkins — Darien's Tips  
**Version:** 1.0  
**Created / updated:** September 20, 2026  

## Overview

The video starts with a Windows notification that says Microsoft Defender Antivirus is turned off while Windows Security indicates that real-time protection is enabled. It uses `Get-MpComputerStatus` to inspect protection state directly, checks a remote Windows Server Core system with `Invoke-Command`, explains three component versions, and demonstrates manual updates followed by verification.

The accompanying `.ps1` is a **command reference, not an unattended installer or remediation script**. Open it in an editor, review the comments, and run the required commands interactively in an elevated Windows PowerShell session. A `throw` statement before the examples intentionally prevents accidentally executing the entire file.

The command bodies and their order come from the final video script. Lab computer names are replaced with `CLIENT-NAME` and `SERVER-NAME`. The original version-specific download URL, variable names, selected properties, command parameters, SHA-1 algorithm, and installation order are retained. Header information, section comments, and the safety stop are companion-file additions; they are not additional video demonstrations. Recording filenames and the audio-production clipboard expression are omitted.

## Files

| File | Purpose |
| --- | --- |
| `README.md` | Scope, prerequisites, usage, interpretation, safety notes, and official documentation. |
| `Microsoft-Defender-Antivirus-Status-Updates-Command-Reference.ps1` | Section-by-section PowerShell command reference. |

## Scope and prerequisites

Use a Windows client or Windows Server system with Microsoft Defender Antivirus and the Defender PowerShell module available. The reference uses **elevated Windows PowerShell 5.1**; it is not a PowerShell 7-specific walkthrough. The executable downloads shown are **x64 / amd64** examples, not packages for every architecture.

The remote status query requires a reachable, authorized target with PowerShell remoting enabled and the necessary permissions. `Start-BitsTransfer` requires the BitsTransfer module, access to the relevant Microsoft endpoints, and an existing writable `$env:USERPROFILE\Downloads` directory. Adapt paths when Downloads is redirected or unavailable, including on Server Core.

**The remote query does not redirect later commands to the remote computer.** Only the `Invoke-Command` block operates on the named target. The standalone downloads, signature checks, and installers run on the computer hosting the current PowerShell session. To maintain a different system, deliberately establish the appropriate administrative session on that system and review the paths and packages there.

## September 2026 issue and version context

The video uses **Defender Antivirus platform 4.18.26080.4** under **KB4052623**. Microsoft's release-health entry identifies this version, released September 17, 2026, as the resolution for the incorrect “Microsoft Defender Antivirus is turned off” notification. The issue was opened August 28, 2026. The original entry describes notifications at startup and intermittently afterward, even while antivirus protection remained operational.

https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-25h2#4956msgdesc

This is a specific documented notification issue, not a reason to dismiss every antivirus warning. Confirm protection state before attributing a notification to that issue.

The platform download URL retained in the code is a **fixed historical example**. It does not automatically retrieve the latest platform. For ongoing maintenance, choose the currently approved package appropriate to the system from the Microsoft Update Catalog and update `$defenderPlatformDownloadUrl` and the adjacent version comment. Do not downgrade a newer working platform merely to match the video.

https://www.catalog.update.microsoft.com/Search.aspx?q=KB4052623

## What you will learn

- Verify Microsoft Defender Antivirus status with Get-MpComputerStatus.
- Check real-time protection, antivirus service status, and AMRunningMode.
- Query remote Windows clients and Windows Server Core with Invoke-Command.
- Distinguish Defender platform, engine, and security-intelligence versions.
- Download the KB4052623 platform update from Microsoft Update Catalog.
- Compare file hashes and inspect Authenticode signatures before installation.
- Manually update Defender security intelligence with mpam-fe.exe.
- Verify protection and update versions, then recheck after a restart.

## Workflow matching the video

### B — Verify Defender Antivirus Status with PowerShell

Run the local status block before installing anything. Record or retain its output for comparison. The selected fields include antivirus enablement, real-time protection, service status, running mode, security-intelligence version and age, engine version, and platform version.

The remote block uses the same property selection through `Invoke-Command`. Replace the sample computer name with a computer you are authorized to administer. Server Core is a useful example because the check does not depend on the Windows Security graphical interface.

The expected active-mode state shown in the video is:

```text
AntivirusEnabled          : True
RealTimeProtectionEnabled : True
AMServiceEnabled          : True
AMRunningMode             : Normal
```

These expectations apply when Defender Antivirus is intended to be the primary antivirus provider. Microsoft defines `Normal` as active mode. A different mode needs interpretation in the context of the device's antivirus configuration; do not treat it as this notification bug automatically.

https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows

### C — Understand Defender's Version Numbers

| PowerShell property | Component | How it is used in this walkthrough |
| --- | --- | --- |
| `AMProductVersion` | Microsoft Defender Antivirus platform | Identify the platform version and verify installation of the applicable KB4052623 package. |
| `AMEngineVersion` | Microsoft antimalware engine | Inspect the engine independently; it need not change with every update. |
| `AntivirusSignatureVersion` | Microsoft Defender security intelligence | Identify the installed threat-intelligence package. |
| `AntivirusSignatureLastUpdated` | Security-intelligence update timestamp | Compare the last-update information before and after installation. |

These are three separate version numbers, not alternative labels for a single product version. Microsoft's servicing documentation distinguishes platform updates under KB4052623 from security-intelligence updates and explains that engine updates are delivered with security-intelligence updates when released. Installing the same engine again need not change `AMEngineVersion`.

https://learn.microsoft.com/en-us/defender-endpoint/evaluate-mda-using-mde-security-settings-management#check-the-platform-update-version

https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-updates

### D — Manually Update the Defender Antivirus Platform and Security Intelligence

The reference preserves the video's sequence: download the platform package, select it and inspect its hash, inspect its Authenticode signature, download and inspect the security-intelligence package, then install the platform followed by security intelligence.

**Select the intended platform file.** The original `Get-ChildItem` pipeline selects the newest-modified `updateplatform*.exe` in Downloads. Its ordering does not prove that the file is the intended download, version, or architecture. Confirm the selected full path before continuing, especially when multiple packages are present.

**Treat the SHA-1 step as a comparison, not authentication.** `Get-FileHash -Algorithm SHA1` displays the downloaded package's hash for manual comparison with the hash in the official Catalog-generated filename. The code does not automatically compare the two. Microsoft documents SHA-1 as unsuitable for protection against attack or tampering; it is retained here only to reproduce the demonstrated simple comparison. A matching filename hash is not sufficient evidence of Microsoft publisher identity.

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-5.1

**Inspect both executable signatures before installation.** `Get-AuthenticodeSignature` displays `Status`, `StatusMessage`, and `SignerCertificate`. Require a valid signature and check that the certificate identifies the expected Microsoft publisher. `Status = Valid` alone does not identify the publisher. Stop and investigate an unexpected signer or invalid signature. These commands display information; they do not conditionally block the later installation commands.

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-authenticodesignature?view=powershell-7.5

The source uses this Microsoft x64 security-intelligence download link and stores the result as `mpam-fe.exe`:

```text
https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64
```

The filename is fixed, but the downloaded contents can change as Microsoft publishes security intelligence. The platform package is a different download. Use the appropriate architecture and review both packages before executing them.

The two `Start-Process -Wait` commands run the platform installer and then the security-intelligence installer on the local computer. Waiting for a process to finish is not, by itself, proof of successful installation. Check the resulting versions in Section E.

### E — Verify the Result

Run the final `Get-MpComputerStatus` block and compare it with the output captured before updating. For the active Defender configuration demonstrated, review `AntivirusEnabled`, `RealTimeProtectionEnabled`, `AMServiceEnabled`, and `AMRunningMode` separately from the version fields.

Check `AMProductVersion` for the platform you intended to install. The video's version is `4.18.26080.4`; later maintenance should use the relevant current approved package rather than treating that number as permanently current.

Inspect `AntivirusSignatureVersion`, `AntivirusSignatureLastUpdated`, `AntivirusSignatureAge`, and `DefenderSignaturesOutOfDate`. An out-of-date flag of `False` is useful status information, not proof that no newer intelligence has been published since the last update. Compare with the intended package and Microsoft's update page as appropriate. If the package is already current, installing it again does not necessarily change a version or timestamp.

An unchanged `AMEngineVersion` does not, by itself, indicate failure: the installed engine may already be the version included with the security-intelligence package.

The video then restarts the system and revisits Windows Security. Schedule the restart appropriately, sign back in, recheck the symptom, and rerun the status check. The reference deliberately adds no automatic restart command. Record whether the notification recurs; a single restart without an intermittent notification is not proof that it can never recur.

The final script's Windows Security observation refers specifically to **Virus & threat protection > Protection updates**. It should not be read as a claim that every Windows Security page omits platform and engine information.

## Reading the status without overclaiming

Protection-state fields answer whether Defender reports that protection is operating. Version fields identify the installed components. A status query does not scan the computer, prove the absence of malware, or demonstrate every protection feature end to end. Follow up on unexpected output rather than assuming all warnings are false.

## Customization checklist

Replace the example computer name before a remote query. Confirm the destination directory exists and is writable. Review the fixed platform URL for the intended version and architecture. Inspect the selected executable path, manually compare any expected hash, and review both digital signatures before running installation commands. Keep the selected package variables in the same PowerShell session while performing the dependent steps.

## Links and resources

https://learn.microsoft.com/en-us/windows/release-health/status-windows-11-25h2#4956msgdesc

https://www.microsoft.com/en-us/wdsi/defenderupdates

https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-updates

https://www.catalog.update.microsoft.com/Search.aspx?q=KB4052623

https://learn.microsoft.com/en-us/powershell/module/defender/get-mpcomputerstatus?view=windowsserver2025-ps

https://learn.microsoft.com/en-us/defender-endpoint/manage-protection-updates-microsoft-defender-antivirus

https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows

https://learn.microsoft.com/en-us/defender-endpoint/evaluate-mda-using-mde-security-settings-management#check-the-platform-update-version

https://learn.microsoft.com/en-us/powershell/module/bitstransfer/start-bitstransfer?view=windowsserver2025-ps

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-5.1

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-authenticodesignature?view=powershell-7.5

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command?view=powershell-5.1

## Video and repository

Video title: **Windows Says Microsoft Defender Is Turned Off — Verify It with PowerShell**

Video URL: [Add the published video URL.]

Repository URL: [Add this repository's URL.]

Channel:
https://www.youtube.com/@darienstips9409

GitHub profile:
https://github.com/DariensTips

## Disclaimer

Educational demonstration and command reference, provided as-is without warranty. Review every command, verify computer names and package paths, test changes appropriately, and follow your organization's security and change-management policies. Use current Microsoft documentation and updates suitable for the system. Not every Defender-off notification is false. The reference does not disable antivirus protection, automate remediation, or guarantee that a computer is free of malware.
