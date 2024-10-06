Import-Module ./Az.ADB2C.psm1
./aadb2c-nb-create-graph-app.ps1
Connect-AzADB2C -ConfigPath ./b2cAppSettings_a73csygrwfojk.json 
Enable-AzADB2CIdentityExperienceFramework
New-AzADB2CLocalAdmin -u "graphexplorer" -RoleNames @("Global Administrator")
rem New-AzADB2CLocalAdmin -u "alice@contoso.com" -DisplayName "Alice Contoso" -RoleNames @()
New-AzADB2CTestApp -DisplayName a73csygrwfojkTestApp