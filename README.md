# Nico's PowerShell Profile

Here is my personal PowerShell profile. 

## Requirements
The following PowerShell modules are required:
- Oh-My-Posh (https://github.com/JanDeDobbeleer/oh-my-posh)
- KNSModulesDocsGenerator (https://github.com/kns7/KNSModulesDocsGenerator)

## Install
First clone the Repo

```powershell
git clone git@github.com:nicolaskapfer/psprofile.git ~/.psprofile
```
Then link the Profile to "Current User / Current Host" aka `$profile`

```powershell
New-Item -Path $profile -Target ~\.psprofile\Microsoft.PowerShell_profile.ps1
```
