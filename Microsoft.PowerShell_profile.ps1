Write-Host "    Running personal Profile"

# Import Modules
Import-Module oh-my-posh
Import-Module KNSModulesDocsGenerator

# Functions Definition for Aliases
function Get-GitStatus { git.exe status }
function Get-GitPull { git.exe pull }
function Get-GitPush { git.exe push }
function Set-HomePS { Set-Location "~\OneDrive - Emma Sleep GmbH\Dokumente\WindowsPowerShell\"}

# Define Aliases
New-Alias -Name gstatus -Value Get-GitStatus
New-Alias -Name gpull -Value Get-GitPull
New-Alias -Name gpush  -Value Get-GitPush
New-Alias -Name cdps -Value Set-HomePS

Write-Host "    Set some known Path"
$me = @{
   scripts = "~\OneDrive - Emma Sleep GmbH\Dokumente\WindowsPowerShell\Scripts\"
   modules = "~\OneDrive - Emma Sleep GmbH\Dokumente\WindowsPowerShell\Modules\"
   devs = "~\devs\"
   gitprovisioning = "~\devs\github-provisioning\etc\iac\provisioning\resources\repositories-definitions\it-repositories"
}

# Add SSH Key
ssh-add

# Set Oh-My-Posh
oh-my-posh --init --shell pwsh --config ~\.psprofile\nicolaskapfer.omp.json | Invoke-Expression

# Fix for Connect-ExchangeOnline
# (https://cloudinfra.net/how-to-fix-error-new-exopssession-create-powershell-session-is-failed-using-oauth/) 
if((Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" -Name "AllowBasic").AllowBasic -eq 0){
   if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
      Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client -Name AllowBasic -Value 1`"" -Verb RunAs
      exit 
   }
}
