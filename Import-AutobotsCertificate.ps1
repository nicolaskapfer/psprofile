Import-Module psmodule-credentials
Get-LoggedUser -Reload

# Removing the Certificate
Get-ChildItem Cert:\LocalMachine\My\ada909043ea4385a15e5d5f812372b1b6efb8139 | Remove-Item

# Get Certificate password
$certpwd = ConvertTo-SecureString -String (Set-CredentialFromFile -Type Autobotscertificate) -AsPlainText -Force

# Import the Certificate
Import-PFXCertificate -FilePath C:\Users\nicolaskapfer\.credentials\EmmaIT-Autobots.pfx -CertStoreLocation Cert:\LocalMachine\My -Password $certpwd

#$certpassword = Set-CredentialFromFile -Type Autobotscertificate | ConvertTo-SecureString

#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
#    #$certpassword = Get-Credential -UserName "Autobots Certificate"
#    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"Import-Module psmodule-credentials; Get-LoggedUser -Reload; $certpwd = ConvertTo-SecureString -String (Set-CredentialFromFile -Type Autobotscertificate) -AsPlainText -Force ; Import-PFXCertificate -FilePath C:\Users\nicolaskapfer\.credentials\EmmaIT-Autobots.pfx -CertStoreLocation Cert:\LocalMachine\My -Password $certpwd; Start-Sleep 10`"" -Verb RunAs
#    #Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"Write-Host $($certpassword.Password); Start-Sleep 2`"" -Verb RunAs
#    exit
#}