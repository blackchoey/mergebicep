// Global
param resourceBaseName string
param m365ClientId string
@secure()
param m365ClientSecret string
param m365TenantId string
param m365OauthAuthorityHost string

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxGlobalConfigurations = {
  m365ApplicationIdUri: 'api://${frontendHostingProvision.outputs.domain}/botid-${bot_aadClientId}'
}

// Frontend hosting
param frontendHosting_storageName string = 'frontendstg${uniqueString(resourceBaseName)}'

module frontendHostingProvision './frontendHostingProvision.bicep' = {
  name: 'frontendHostingProvision'
  params: {
    frontendHostingStorageName: frontendHosting_storageName
  }
}

// Simple auth
param simpleAuth_sku string = 'F1'
param simpleAuth_serverFarmsName string = '${resourceBaseName}-simpleAuth-serverfarms'
param simpleAuth_webAppName string = '${resourceBaseName}-simpleAuth-webapp'
param simpleAuth_packageUri string = 'https://github.com/OfficeDev/TeamsFx/releases/download/simpleauth@0.1.0/Microsoft.TeamsFx.SimpleAuth_0.1.0.zip'

module simpleAuthProvision './simpleAuthProvision.bicep' = {
  name: 'simpleAuthProvision'
  params: {
    simpleAuthServerFarmsName: simpleAuth_serverFarmsName
    simpleAuthWebAppName: simpleAuth_webAppName
    httpsOnly: true
    sku: simpleAuth_sku
  }
}
module simpleAuthConfiguration './simpleAuthConfiguration.bicep' = {
  name: 'simpleAuthConfiguration'
  dependsOn: [
    simpleAuthProvision
  ]
  params: {
    simpleAuthWebAppName: simpleAuth_webAppName
    simpelAuthPackageUri: simpleAuth_packageUri
    teamsFxConfiguration: teamsFxSimpleAuthConfigurations
  }
}

var teamsFxSimpleAuthConfigurationInput = {
  m365ClientId: m365ClientId
  m365ClientSecret: m365ClientSecret
  m365TenantId: m365TenantId
  m365OAuthAuthorityHost: m365OauthAuthorityHost
  m365ApplicationIdUri: teamsFxGlobalConfigurations.m365ApplicationIdUri
  frontendHostingEndpoitn: frontendHostingProvision.outputs.endpoint
}

// Function 
var teamsFxFunctionProvisionInput = {
  identityName: userAssignedIdentityProvision.outputs.identityName
}

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxFunctionConfigurationInput = {
  // m365ClientId: m365ClientId
  // m365ClientSecret: m365ClientSecret
  // m365TenantId: m365TenantId
  // m365ApplicationIdUri: teamsFxGlobalConfigurations.m365ApplicationIdUri
  // m365OauthAuthorityHost: m365OauthAuthorityHost
  // frontendHostingStorageEndpoint: frontendHostingProvision.outputs.endpoint
  // sqlDatabaseName: azureSqlProvision.outputs.databaseName
  // sqlEndpoint: azureSqlProvision.outputs.sqlEndpoint
  // identityId: userAssignedIdentityProvision.outputs.identityId
  appSettings: {
    properties: {
      m365ClientId: m365ClientId
      m365ClientSecret: m365ClientSecret
      m365TenantId: m365TenantId
      m365ApplicationIdUri: teamsFxGlobalConfigurations.m365ApplicationIdUri
      m365OauthAuthorityHost: m365OauthAuthorityHost
      frontendHostingStorageEndpoint: frontendHostingProvision.outputs.endpoint
      sqlDatabaseName: azureSqlProvision.outputs.databaseName
      sqlEndpoint: azureSqlProvision.outputs.sqlEndpoint
      identityId: userAssignedIdentityProvision.outputs.identityId
    }
  }
}


param function_serverfarmsName string = '${resourceBaseName}-function-serverfarms'
param function_webappName string = '${resourceBaseName}-function-webapp'
param function_storageName string = 'functionstg${uniqueString(resourceBaseName)}'

module functionProvision './functionProvision.bicep' = {
  name: 'functionProvision'
  params: {
    functionAppName: function_webappName
    functionServerfarmsName: function_serverfarmsName
    functionStorageName: function_storageName
    teamsFxConfiguration: teamsFxFunctionProvisionInput
  }
}
module functionConfiguration './functionConfiguration.bicep' = {
  name: 'functionConfiguration'
  dependsOn: [
    functionProvision
  ]
  params: {
    functionAppName: function_webappName
    functionStorageName: function_storageName
    teamsFxConfiguration: teamsFxFunctionConfigurationInput
  }
}

// Bot
var teamsFxBotProvisionInput = {
  identityName: userAssignedIdentityProvision.outputs.identityName
}

// 
var teamsFxBotConfigurationInput = {
  authLoginUriSuffix: authLoginUriSuffix
  botEndpoint: botProvision.outputs.botWebAppEndpoint
  m365ApplicationIdUri: m365ApplicationIdUri
  m365ClientId: m365ClientId
  m365ClientSecret: m365ClientSecret
  m365TenantId: m365TenantId
  m365OauthAuthorityHost: m365OauthAuthorityHost
  functionEndpoint: functionProvision.outputs.functionEndpoint
  sqlDatabaseName: azureSqlProvision.outputs.databaseName
  sqlEndpoint: azureSqlProvision.outputs.sqlEndpoint
  identityId: userAssignedIdentityProvision.outputs.identityId
}

param bot_aadClientId string
@secure()
param bot_aadClientSecret string
param bot_serviceName string = '${resourceBaseName}-bot-service'
param bot_displayName string = '${resourceBaseName}-bot-displayname'
param bot_serverfarmsName string = '${resourceBaseName}-bot-serverfarms'
param bot_webAppSKU string = 'F1'
param bot_serviceSKU string = 'F1'
param bot_sitesName string = '${resourceBaseName}-bot-sites'
param authLoginUriSuffix string = 'auth-start.html'

module botProvision './botProvision.bicep' = {
  name: 'botProvision'
  params: {
    botServerfarmsName: bot_serverfarmsName
    botServiceName: bot_serviceName
    botAadClientId: bot_aadClientId
    botDisplayName: bot_displayName
    botServiceSKU: bot_serviceSKU
    botWebAppName: bot_sitesName
    botWebAppSKU: bot_webAppSKU
  }
}
module botConfiguration './botConfiguration.bicep' = {
  name: 'botConfiguration'
  dependsOn: [
    botProvision
  ]
  params: {
    botAadClientId: bot_aadClientId
    botAadClientSecret: bot_aadClientSecret
    botServiceName: bot_serviceName
    botWebAppName: bot_sitesName
  }
}

output teamsFxBotOutput object = {
  
}

// Identity
param identity_managedIdentityName string = '${resourceBaseName}-managedIdentity'

module userAssignedIdentityProvision './userAssignedIdentityProvision.bicep' = {
  name: 'userAssignedIdentityProvision'
  params: {
    managedIdentityName: identity_managedIdentityName
  }
}

// SQL
param azureSql_admin string
@secure()
param azureSql_adminPassword string
param azureSql_serverName string = '${resourceBaseName}-sql-server'
param azureSql_databaseName string = '${resourceBaseName}-database'

module azureSqlProvision './azureSqlProvision.bicep' = {
  name: 'azureSqlProvision'
  params: {
    sqlServerName: azureSql_serverName
    sqlDatabaseName: azureSql_databaseName
    administratorLogin: azureSql_admin
    administratorLoginPassword: azureSql_adminPassword
  }
}

// do not modify
output teamsFxFeOutput object = {

}


output frontendHosting_storageName string = frontendHostingProvision.outputs.storageName
output frontendHosting_endpoint string = frontendHostingProvision.outputs.endpoint
output frontendHosting_domain string = frontendHostingProvision.outputs.domain
output identity_identityName string = userAssignedIdentityProvision.outputs.identityName
output identity_identityId string = userAssignedIdentityProvision.outputs.identityId
output identity_identity string = userAssignedIdentityProvision.outputs.identity
output azureSql_sqlEndpoint string = azureSqlProvision.outputs.sqlEndpoint
output azureSql_databaseName string = azureSqlProvision.outputs.databaseName
output bot_webAppSKU string = botProvision.outputs.botWebAppSKU
output bot_serviceSKU string = botProvision.outputs.botServiceSKU
output bot_webAppName string = botProvision.outputs.botWebAppName
output bot_domain string = botProvision.outputs.botDomain
output bot_appServicePlanName string = botProvision.outputs.appServicePlanName
output bot_serviceName string = botProvision.outputs.botServiceName
output bot_webAppEndpoint string = botProvision.outputs.botWebAppEndpoint
output function_storageAccountName string = functionProvision.outputs.storageAccountName
output function_appServicePlanName string = functionProvision.outputs.appServicePlanName
output function_functionEndpoint string = functionProvision.outputs.functionEndpoint
output function_appName string = functionProvision.outputs.appName
output simpleAuth_skuName string = simpleAuthProvision.outputs.skuName
output simpleAuth_endpoint string = simpleAuthProvision.outputs.endpoint
output simpleAuth_webAppName string = simpleAuthProvision.outputs.webAppName
output simpleAuth_appServicePlanName string = simpleAuthProvision.outputs.appServicePlanName
