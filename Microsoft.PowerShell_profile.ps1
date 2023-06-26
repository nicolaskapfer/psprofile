Write-Host "    Running personal Profile" -ForegroundColor Cyan

# Import Modules
#Import-Module oh-my-posh -UseWindowsPowerShell
Import-Module KNSModulesDocsGenerator -Force 3>$null

Write-Host "    Import personal configuration" -ForegroundColor DarkCyan
# Import Config
$myconfig = Import-Config "~\.psprofile\config.json"

# Functions Definition for Aliases
function Set-HomePS { Set-Location "~\OneDrive - Emma Sleep GmbH\Dokumente\PowerShell\"}

# Define Aliases
New-Alias -Name cdps -Value Set-HomePS

Write-Host "    Set some known Path" -ForegroundColor DarkCyan
$PS5 = @{
   scripts = "~\OneDrive - Emma Sleep GmbH\Dokumente\WindowsPowerShell\Scripts\"
   modules = "~\OneDrive - Emma Sleep GmbH\Dokumente\WindowsPowerShell\Modules\"
   devs = "~\devs\"
   gitprovisioning = "~\devs\github-provisioning\etc\iac\provisioning\resources\repositories-definitions\it-repositories"
}
$PS = @{
   scripts = "~\OneDrive - Emma Sleep GmbH\Dokumente\PowerShell\Scripts\"
   modules = "~\OneDrive - Emma Sleep GmbH\Dokumente\PowerShell\Modules\"
   devs = "~\devs\"
   gitprovisioning = "~\devs\github-provisioning\etc\iac\provisioning\resources\repositories-definitions\it-repositories"
}

Write-Host "    Set Properties for Microsoft.Graph" -ForegroundColor DarkCyan
$MgProperties = @{
   Scope  = "User.ReadWrite.All", "Group.ReadWrite.All"
   Users  = "AccountEnabled","City","CompanyName","Department","DisplayName","EmployeeHireDate","EmployeeId","EmployeeType","Givenname","Id","JobTitle","Mail","MailNickname","Manager","ProxyAddresses","State","StreetAddress","Surname","UsageLocation","UserPrincipalName","UserType"
   Groups = "AssignedLabels", "AssignedLicenses", "DisplayName", "AutoSubscribeNewMembers", "CreatedDateTime", "DeletedDateTime", "Description", "DisplayName", "ExpirationDateTime", "Extensions", "HideFromAddressLists", "Mail", "MailEnabled", "MailNickname", "MemberOf", "Members", "MembershipRule", "Owners", "ProxyAddresses", "RejectedSenders","SecurityEnabled","Settings","Site", "Visibility", "AdditionalProperties"
}

Write-Host "    Adding SSH Key" -ForegroundColor DarkCyan
# Add SSH Key
ssh-add

Write-Host "    Initiate Oh-my-Posh" -ForegroundColor DarkCyan
# Set Oh-My-Posh
oh-my-posh --init --shell pwsh --config ~\.psprofile\nicolaskapfer.omp.json | Invoke-Expression

# Fix for Connect-ExchangeOnline
# (https://cloudinfra.net/how-to-fix-error-new-exopssession-create-powershell-session-is-failed-using-oauth/) 
#if((Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" -Name "AllowBasic").AllowBasic -eq 0){
#   Write-Host "    Fixing OAuth for Exchange Online connection"
#   if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
#      Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client -Name AllowBasic -Value 1`"" -Verb RunAs
#      exit
#   }
#}

# Fix for problematic Certificate (Autobots)
#Write-Host "    Import Autobots certificate" -ForegroundColor DarkCyan
#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
#   Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `".psprofile\Import-AutobotsCertificate.ps1`"" -Verb RunAs
#   exit
#}

Write-Host "    Connecting to Microsoft Graph..." -ForegroundColor DarkCyan
Connect-MgGraph -Scopes $MgProperties.Scope

Write-Host "    Connecting to Azure..." -ForegroundColor DarkCyan 
Connect-AzAccount -Subscription $myconfig.Azure.Subscriptions.EmmaIT -AccountId $myconfig.Azure.Account | Out-Null

# Change IP Access for Home Office (on Animatronio)
$homeofficeIP = (Resolve-DnsName $myconfig.HomeOffice.Hostname).IPAddress
Write-Host "    Home Office IP: $($homeofficeIP)" -ForegroundColor Blue
$nsg = Get-AzNetworkSecurityGroup -Name $myconfig.Azure.VMs.Animatronio.NSG -ResourceGroupName $myconfig.Azure.Vms.Animatronio.RG
$fwr = $nsg | Get-AzNetworkSecurityRuleConfig -Name $myconfig.Azure.VMs.Animatronio.Rule
if($fwr.SourceAddressPrefix[0] -ne $homeofficeIP){
   Write-Host "    Updating Firewall Rules for Animatronio" -ForegroundColor DarkRed
   $params = @{
      Name                       = $myconfig.Azure.VMs.Animatronio.Rule
      SourceAddressPrefix        = $homeofficeIP
      NetworkSecurityGroup       = $nsg
      Description                = "Allow IP Address from Home Office for $($env:USERNAME) (Updated: $(Get-Date -Format "dd/MM/yyyy"))"
      Access                     = $fwr.Access
      Protocol                   = $fwr.Protocol
      Direction                  = $fwr.Direction
      Priority                   = $fwr.Priority
      DestinationAddressPrefix   = $fwr.DestinationAddressPrefix
      DestinationPortRange       = $fwr.DestinationPortRange
      SourcePortRange            = $fwr.SourcePortRange

   }

   Set-AzNetworkSecurityRuleConfig @params
   Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg
}