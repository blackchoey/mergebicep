param resourceBaseName string
param m365ClientId string
@secure()
param m365ClientSecret string
param m365TenantId string
param m365OauthAuthorityHost string

var teamsMobileOrDesktopAppClientId = '1fec8e78-bce4-4aaf-ab1b-5451cc387264'
var teamsWebAppClientId = '5e3ce6c0-2b1f-4285-8d4b-75ee78787346'

// AAD
var teamsFxAuthenticationConfiguration = {
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
    sku: simpleAuth_sku
    teamsFxConfiguration: teamsFxSimpleAuthProvisionInput
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
    teamsFxConfiguration: teamsFxSimpleAuthConfigurationInput
  }
}

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxSimpleAuthProvisionInput = {
  webApp: {
    identity: {}
  }
}

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxSimpleAuthConfigurationInput = {
  appSettings: {
    properties: {
      AAD_METADATA_ADDRESS: uri(m365OauthAuthorityHost, '${m365TenantId}/v2.0/.well-known/openid-configuration')
      ALLOWED_APP_IDS: '${teamsMobileOrDesktopAppClientId};${teamsWebAppClientId}'
      IDENTIFIER_URI: teamsFxAuthenticationConfiguration.m365ApplicationIdUri
      CLIENT_ID: m365ClientId
      CLIENT_SECRET: m365ClientSecret
      OAUTH_AUTHORITY: m365OauthAuthorityHost
      TAB_APP_ENDPOINT: frontendHostingProvision.outputs.endpoint
    }
  }
}

// Function 
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

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxFunctionProvisionInput = {
  funtionApp: {
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${userAssignedIdentityProvision.outputs.identityName}': {}
      }
    }
  }
}

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxFunctionConfigurationInput = {
  appConfig: {
    properties: {
      cors: {
        allowedOrigins: [
          frontendHostingProvision.outputs.endpoint
        ]
      }
    }
  }
  appSettings: {
    properties: {
      API_ENDPOINT: 'https://${functionProvision.outputs.hostName}'
      ALLOWED_APP_IDS: '${teamsMobileOrDesktopAppClientId};${teamsWebAppClientId}'
      M365_APPLICATION_ID_URI: teamsFxAuthenticationConfiguration.m365ApplicationIdUri
      M365_CLIENT_ID: m365ClientId
      M365_CLIENT_SECRET: m365ClientSecret
      M365_TENANT_ID: m365TenantId
      M365_AUTHORITY_HOST: m365OauthAuthorityHost
      IDENTITY_ID: userAssignedIdentityProvision.outputs.identityName
      SQL_DATABASE_NAME: azureSqlProvision.outputs.databaseName
      SQL_ENDPOINT: azureSqlProvision.outputs.sqlEndpoint
    }
  }
}

// Bot
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
    teamsFxConfiguration: teamsFxBotProvisionInput
  }
}
module botConfiguration './botConfiguration.bicep' = {
  name: 'botConfiguration'
  dependsOn: [
    botProvision
  ]
  params: {
    botServiceName: bot_serviceName
    botWebAppName: bot_sitesName
    teamsFxConfiguration: teamsFxBotConfigurationInput
  }
}

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxBotProvisionInput = {
  webApp: {
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${userAssignedIdentityProvision.outputs.identityName}': {}
      }
    }
  }
}

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
var teamsFxBotConfigurationInput = {
  webAppSettings: {
    properties: {
      BOT_ID: bot_aadClientId
      BOT_PASSWORD: bot_aadClientSecret
      INITIATE_LOGIN_ENDPOINT: uri(botProvision.outputs.botWebAppEndpoint, authLoginUriSuffix)
      M365_APPLICATION_ID_URI: teamsFxAuthenticationConfiguration.m365ApplicationIdUri
      M365_AUTHORITY_HOST: m365OauthAuthorityHost
      M365_CLIENT_ID: m365ClientId
      M365_CLIENT_SECRET: m365ClientSecret
      M365_TENANT_ID: m365TenantId
      API_ENDPOINT: functionProvision.outputs.functionEndpoint
      SQL_DATABASE_NAME: azureSqlProvision.outputs.databaseName
      SQL_ENDPOINT: azureSqlProvision.outputs.sqlEndpoint
      IDENTITY_ID: userAssignedIdentityProvision.outputs.identityName
    }
  }
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

// Auto generated TeamsFx internal configurations. Changes to them will be overriden.
output teamsFxOutput object = {
  'fx-resource-frontend-hosting': {

  }
  'fx-resource-identity': {

  }
  'fx-resource-azure-sql': {

  }
  'fx-resource-bot': {

  }
  'fx-resource-aad-app-for-teams': {

  }
  'fx-resource-function': {

  }
  'fx-resource-simple-auth': {
    
  }
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
