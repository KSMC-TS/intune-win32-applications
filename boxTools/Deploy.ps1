<#
.DESCRIPTION
- Use this to launch PSAppDeployToolkit to stop dependencies and allow for deferral of application install.
- Leveraging ServiceUI.exe from MDT to present PSAppDeployToolkit UI to user for interactivity.
- Thanks to @Svdbusse for providing the framework and a portion of this script: https://svdbusse.github.io/SemiAnnualChat/2019/09/14/User-Interactive-Win32-Intune-App-Deployment-with-PSAppDeployToolkit.html
.PARAMETER Uninstall
- Pass this switch parameter to uninstall. The default value is false (for install rather than uninstall).
.NOTES
    Version:        0.3
    Last updated:   12/01/2020
    Modified by:    Zachary Choate
#>

[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $uninstall = $false
)


## Build a hashtable since this will be easier for people to modify.
## Put your values in single quotes.
$hashtable = @{
    InstallerType   = 'msi'
    InstallerFile   = 'BoxTools.msi'
    InstallerArgs   = '/qn'
    AppName         = 'Box Edit'
    AppVendor       = 'Box'
    StopProcess     = 'Box Edit'
}

## Download prereqs/installers - comment this out if installer is bundled.
If(-not $uninstall) {
    If(!(Test-Path "$PSScriptRoot/Files")) {
        New-Item -ItemType Directory -Name Files
    }
    Invoke-RestMethod -Method Get -Uri "https://e3.boxcdn.net/box-installers/boxedit/win/currentrelease/BoxToolsInstaller-AdminInstall.msi" -OutFile "$PSScriptRoot/Files/$($hashtable.InstallerFile)"
}

# Don't modify below this

$targetprocesses = Get-Process $hashtable.StopProcess.Split(",") -IncludeUserName -ErrorAction SilentlyContinue
if ($targetprocesses.Count -eq 0) {
    Try {
        Write-Output "No user logged in, running without ServiceUI"
        $hashtable.Add("DeployMode","`"NonInteractive`"")
        If($uninstall) {
            $hashtable.Add("DeploymentType","Uninstall")
            $argumentList = $hashtable.GetEnumerator().ForEach({ "-$($_.Name) `'$($_.Value)`'" }) -join " "
            Start-Process Deploy-Application.exe -Wait -ArgumentList $argumentList
        } Else {
            $argumentList = $hashtable.GetEnumerator().ForEach({ "-$($_.Name) `'$($_.Value)`'" }) -join " "
            Start-Process Deploy-Application.exe -Wait -ArgumentList $argumentList
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $ErrorMessage
    }
}
else {
    Foreach ($targetprocess in $targetprocesses) {
        $Username = $targetprocess.UserName
        Write-output "$Username logged in, running with ServiceUI"
    }
    Try {
        If($uninstall) {
            $hashtable.Add("DeploymentType", "Uninstall")
            $argumentList = $hashtable.GetEnumerator().ForEach({ "-$($_.Name) `'$($_.Value)`'" }) -join " "
            .\ServiceUI.exe -Process:explorer.exe Deploy-Application.exe $argumentList
        } else {
            $argumentList = $hashtable.GetEnumerator().ForEach({ "-$($_.Name) `'$($_.Value)`'" }) -join " "
            .\ServiceUI.exe -Process:explorer.exe Deploy-Application.exe $argumentList
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $ErrorMessage
    }
}
Write-Output "Install Exit Code = $LASTEXITCODE"
Exit $LASTEXITCODE