Write-Host "    Running personal Profile"

# Import Modules
Import-Module oh-my-posh
Import-Module KNSModulesDocsGenerator

# Functions Definition for Aliases
function get-gitstatus { git.exe status }
function get-gitpull { git.exe pull }
function get-gitpush { git.exe push }

# Define Aliases
New-Alias -Name gstatus -Value get-gitstatus
New-Alias -Name gpull -Value get-gitpull
New-Alias -Name gpush  -Value get-gitpush

# Set Oh-My-Posh
oh-my-posh --init --shell pwsh --config ~\.psprofile\nicolaskapfer.omp.json | Invoke-Expression