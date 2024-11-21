# Bind to Azure AD
$displayName = "B2C-Graph-App"
$TenantName = "nesidonline.onmicrosoft.com"
$DisplayName = "B2C-Graph-App" 

az config set core.login_experience_v2=off
az login --tenant $TenantName --allow-no-subscription
$app = (az ad app create --display-name $DisplayName --identifier-uris "http://$TenantName/$DisplayName" --web-redirect-uris "https://$DisplayName" | ConvertFrom-json)
$credentials = (az ad app credential reset --id $($app.Id) | ConvertFrom-json)
$sp = (az ad sp create --id $app.appId | ConvertFrom-json)
$requiredResourceAccess = @"
[
    {
        "resourceAppId": "00000003-0000-0000-c000-000000000000",
        "resourceAccess": [
                {
					"id": "cefba324-1a70-4a6e-9c1d-fd670b7ae392",
					"type": "Scope"
				},
				{
					"id": "19dbc75e-c2e2-444c-a770-ec69d8559fc7",
					"type": "Role"
				},
				{
					"id": "62a82d76-70ea-41e2-9197-370581804d09",
					"type": "Role"
				},
				{
					"id": "5b567255-7703-4780-807c-7be8301ae99b",
					"type": "Role"
				},
				{
					"id": "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9",
					"type": "Role"
				},
				{
					"id": "df021288-bdef-4463-88db-98f22de89214",
					"type": "Role"
				},
				{
					"id": "246dd0d5-5bd0-4def-940b-0421030a5b68",
					"type": "Role"
				},
				{
					"id": "79a677f7-b79d-40d0-a36a-3e6f8688dd7a",
					"type": "Role"
				},
				{
					"id": "fff194f1-7dce-4428-8301-1badb5518201",
					"type": "Role"
				},
				{
					"id": "4a771c9a-1cf2-4609-b88e-3d3e02d539cd",
					"type": "Role"
				}        ]
    },
    {
        "resourceAppId": "00000002-0000-0000-c000-000000000000",
        "resourceAccess": [
            {
                "id": "311a71cc-e848-46a1-bdf8-97ff7156d8e6",
                "type": "Scope"
            },
            {
                "id": "5778995a-e1bf-45b8-affa-663a9f3f4d04",
                "type": "Role"
            },
            {
                "id": "78c8a3c8-a07e-4b9e-af1b-b5ccab50a175",
                "type": "Role"
            }
                ]
    }
]
"@ | ConvertFrom-json

foreach ( $resApp in $requiredResourceAccess ) {
    $rApp = (az ad sp list --filter "appId eq '$($resApp.resourceAppId)'" | ConvertFrom-json)
    $rApp.DisplayName
    foreach ( $ra in $resApp.resourceAccess ) {
        $ret = (az ad app permission add --id $sp.appId --api $resApp.resourceAppId --api-permissions "$($ra.Id)=$($ra.type)")
        if ( "Scope" -eq $ra.type) {
            $perm = ($rApp.oauth2Permissions | Where-Object { $_.id -eq "$($ra.Id)" })
        }
        else {
            $perm = ($rApp.appRoles | Where-Object { $_.id -eq "$($ra.Id)" })
        }
        $perm.Value
    }        
}

az ad app permission admin-consent --id $sp.appId 

$path = (get-location).Path
$cfg = (Get-Content "$path\b2cAppSettings.json" | ConvertFrom-json)
$cfg.ClientCredentials.client_id = $App.AppId
$cfg.ClientCredentials.client_secret = $credentials.password
$cfg.TenantName = $tenantName
$ConfigFile = "$path\b2cAppSettings_" + $tenantName.split(".")[0] + ".json"
Set-Content -Path $ConfigFile -Value ($cfg | ConvertTo-json) 
write-output "Saved to config file $ConfigFile"

az config set core.login_experience_v2=on
