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
New-Item -Path $profile -Target ~\.psprofile\Microsoft.PowerShell_profile.ps1 -Type SymbolicLink
```

## Configuration
To configure the Profile

Copy the example configuration file
```powershell
cp ~\.psprofile\config.json.example ~\.psprofile\config.json
```

And adapt the configuration to your need

```jsonc
{
    "MGraph": {
        "Scope": [                              // Scopes for the MG-Graph Connection
            "User.ReadWrite.All",
            "Group.ReadWrite.All"
        ],
        "Properties": {                         // List of Properties to be collected from Get-Mg<Resource>
            "Users": [
                "AccountEnabled",
                "City",
                "CompanyName",
                "Department",
                "DisplayName",
                "EmployeeHireDate",
                "EmployeeId",
                "EmployeeType",
                "Givenname",
                "Id",
                "JobTitle",
                "Mail",
                "MailNickname",
                "Manager",
                "onPremisesExtensionAttributes",
                "ProxyAddresses",
                "State",
                "StreetAddress",
                "Surname",
                "UsageLocation",
                "UserPrincipalName",
                "UserType"
            ],
            "Groups": [
                "AssignedLabels",
                "AssignedLicenses",
                "DisplayName",
                "AutoSubscribeNewMembers",
                "CreatedDateTime",
                "DeletedDateTime",
                "Description",
                "DisplayName",
                "ExpirationDateTime",
                "Extensions",
                "HideFromAddressLists",
                "Mail",
                "MailEnabled",
                "MailNickname",
                "MemberOf",
                "Members",
                "MembershipRule",
                "Owners",
                "ProxyAddresses",
                "RejectedSenders",
                "SecurityEnabled",
                "Settings",
                "Site",
                "Visibility",
                "AdditionalProperties"
            ]
        }
    },
    "Azure": {
        "Subscriptions": {
            "EmmaIT": ""                // Subscription ID
        },
        "Account": "",
        "VMs": {                        // List of VMs which need to have their rules adapted
            "Animatronio": {
                "NSG": "",
                "RG": "",
                "Rule": ""
            }
        }
    },
    "HomeOffice": {
        "Hostname": ""                    // DNS Name from Home Office Internet connection, used to adapt the Firewall Rules for VMs
    }
}
```
