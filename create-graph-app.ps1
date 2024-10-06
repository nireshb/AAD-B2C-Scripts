    
$TenantName = "a73csygrwfojk.onmicrosoft.com"
$DisplayName = "B2C-Graph-App"
$AppSecretValue = (New-Guid).Guid.ToString()

$app = (az ad app create --display-name $DisplayName --password $AppSecretValue --identifier-uris "http://$TenantName/$DisplayName" --reply-urls "https://$DisplayName" | ConvertFrom-json)
write-output "AppID`t`t$($app.AppId)`nObjectID:`t$($App.ObjectID)"

write-host "`nCreating ServicePrincipal..."
$sp = (az ad sp create --id $app.appId | ConvertFrom-json)
write-host "AppID`t`t$($sp.AppId)`nObjectID:`t$($sp.ObjectID)"

# foreach( $resApp in $requiredResourceAccess ) {
#     $rApp = (az ad sp list --filter "appId eq '$($resApp.resourceAppId)'" | ConvertFrom-json)
#     $rApp.DisplayName
#     foreach( $ra in $resApp.resourceAccess ) {
#         $ret = (az ad app permission add --id $sp.appId --api $resApp.resourceAppId --api-permissions "$($ra.Id)=$($ra.type)")
#         if ( "Scope" -eq $ra.type) {
#             $perm = ($rApp.oauth2Permissions | where { $_.id -eq "$($ra.Id)"})
#         } else {
#             $perm = ($rApp.appRoles | where { $_.id -eq "$($ra.Id)"})
#         }
#         $perm.Value
#     }        
# }
# az ad app permission admin-consent --id $sp.appId 