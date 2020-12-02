![GitHub release (latest by date)](https://img.shields.io/github/v/release/KSMC-TS/intune-win32-applications) ![GitHub Release Date](https://img.shields.io/github/release-date/KSMC-TS/intune-win32-applications) ![GitHub commits since latest release (by date)](https://img.shields.io/github/commits-since/KSMC-TS/intune-win32-applications/latest) [![Build Status](https://dev.azure.com/ksmc-ts/intune-win32-applications/_apis/build/status/KSMC-TS.intune-win32-applications?branchName=main)](https://dev.azure.com/ksmc-ts/intune-win32-applications/_build/latest?definitionId=1&branchName=main)

# Intune Apps with Azure DevOps Integration

This repo can be forked and connected to Azure DevOps Pipelines for automatic builds of the applications listed:
- Box Drive
- Box Tools (Includes Box Edit)
- Box for Office and Visual Studio Tools for Office 2010 redistributable
- Chrome Enterprise (amd64)
- Firefox (amd64)
- Labtech Agent (include the installer in the files directory)
- Acrobat Reader DC

# Enhancement wishlist
-[] Pull in metadata for applications for easier imports into Microsoft Endpoint Manager
-[] Deploy updated application packages to the connected Intune tenant

# Application Deployment Methodology
The applications in this repo are using a combination of technologies for deployment and are tested for deployment via Intune but may work with other deployment tools such as a Labtech script.
- [PSAppDeployToolkit](https://psappdeploytoolkit.com/)
- The MDT ServiceUI executable as described by @Svdbusse in https://svdbusse.github.io/SemiAnnualChat/2019/09/14/User-Interactive-Win32-Intune-App-Deployment-with-PSAppDeployToolkit.html
- Powershell

1. The Deploy.ps1 is typically the only location that requires configuration. Configure this to use an MSI or EXE installer type. If MSI is selected, msiexec will be used with the install arguments specified in the same file (ex: `/qn`). If EXE is selected, the executable will be run with the specified arguments (ex: `/S /v"/qn"`). Specify the URL if you'd like to download the installer, otherwise comment out the download section and drop your installer in the Files directory.
2. Deploy.ps1 will also allow you to specify applications that need to be stopped for successful deployment. This is where the ServiceUI executable comes into play. Since PSAppDeployToolkit was not designed for use with Intune, we need a way to have any prompts from the installer redirected to the current user session if there is a conflict. ServiceUI will minimize all windows with the PSAppDeployToolkit UI coming into focus. The user can then defer or close the applications as needed.
3. PSAppDeployToolkit runs the installer as desired.

With this deployment methodology, we can push applications via Intune without forcibly closing applications when a user is using a dependent application. Users have the option to defer deployments for a configurable number (this is configurable in Deploy-Application.ps1). We also have a methodology can also be used for application updates. This requires a bit more configuration on the Deploy-Application.ps1 with predeployment tasks but is one of the common uses of PSAppDeployToolkit.