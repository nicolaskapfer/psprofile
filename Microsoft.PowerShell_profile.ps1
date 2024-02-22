Write-Host "    Running personal Profile" -ForegroundColor Cyan

# Import Modules
#Import-Module oh-my-posh -UseWindowsPowerShell
Import-Module KNSModulesDocsGenerator -Force 3>$null

Write-Host "    Initiating Zoxide" -ForegroundColor DarkCyan
Invoke-Expression (& { (zoxide init powershell | Out-String) })

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
   Scope  = $myconfig.MGraph.Scope
   Users  = $myconfig.MGraph.Properties.Users
   Groups = $myconfig.MGraph.Properties.Groups
}

Write-Host "    Adding SSH Key" -ForegroundColor DarkCyan
# Add SSH Key
ssh-add

Write-Host "    Initiate Oh-my-Posh" -ForegroundColor DarkCyan
# Set Oh-My-Posh
oh-my-posh --init --shell pwsh --config ~\.psprofile\nicolaskapfer.omp.json | Invoke-Expression

if([string]::IsNullOrEmpty((Get-MgContext))){
   Write-Host "    Connecting to Microsoft Graph..." -ForegroundColor DarkCyan
   Connect-MgGraph -Scopes $MgProperties.Scopes
}else{
   Write-Host "    Already connected to Microsoft Graph as '$((Get-MgContext).Account)'" -ForegroundColor DarkGreen
}


if([string]::IsNullOrEmpty((Get-AzContext).Account.Id)){
   if((Get-AzContext).Account.Id -ne "a.nicolas.kapfer@emma-sleep.com"){
      Write-Host "    Connecting to Azure...(SubscriptionID: $($myconfig.Azure.Subscriptions.EmmaIT))" -ForegroundColor DarkCyan 
      Connect-AzAccount -Subscription $myconfig.Azure.Subscriptions.EmmaIT -AccountId $myconfig.Azure.Account | Out-Null
   }else{
      Write-Host "    Already connected to Azure as '$((Get-AzContext).Account.Id)'" -ForegroundColor DarkGreen
   }
}else{
   Write-Host "    Already connected to Azure as '$((Get-AzContext).Account.Id)'" -ForegroundColor DarkGreen
}

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