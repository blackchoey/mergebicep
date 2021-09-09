param functionAppName string
param functionStorageName string
@secure()
param teamsFxConfiguration object

resource functionApp 'Microsoft.Web/sites@2021-01-15' existing = {
  name: functionAppName
}

resource functionStorage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: functionStorageName
}

resource functionAppConfig 'Microsoft.Web/sites/config@2021-01-15' = {
  parent: functionApp
  name: 'web'
  kind: 'functionapp'
  properties: {
    cors: teamsFxConfiguration.appConfig.properties.cors
    // cors: {
    //   allowedOrigins: [
    //     frontendHostingStorageEndpoint
    //   ]
    // }
  }
}

resource functionAppAppSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  parent: functionApp
  name: 'appsettings'
  properties: union(teamsFxConfiguration.appSettings.properties, {
    AzureWebJobsDashboard: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};AccountKey=${listKeys(functionStorage.id, functionStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};AccountKey=${listKeys(functionStorage.id, functionStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    FUNCTIONS_EXTENSION_VERSION: '~3'
    FUNCTIONS_WORKER_RUNTIME: 'node'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};AccountKey=${listKeys(functionStorage.id, functionStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    WEBSITE_RUN_FROM_PACKAGE: '1'
    WEBSITE_CONTENTSHARE: toLower(functionAppName)
  })
  // properties: {
  //   API_ENDPOINT: 'https://${functionApp.properties.hostNames[0]}'
  //   ALLOWED_APP_IDS: authorizedClientApplicationIds
  //   AzureWebJobsDashboard: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};AccountKey=${listKeys(functionStorage.id, functionStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  //   AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};AccountKey=${listKeys(functionStorage.id, functionStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  //   FUNCTIONS_EXTENSION_VERSION: '~3'
  //   FUNCTIONS_WORKER_RUNTIME: 'node'
  //   M365_APPLICATION_ID_URI: m365ApplicationIdUri
  //   M365_CLIENT_ID: m365ClientId
  //   M365_CLIENT_SECRET: m365ClientSecret
  //   M365_TENANT_ID: m365TenantId
  //   M365_AUTHORITY_HOST: m365OauthAuthorityHost
  //   WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};AccountKey=${listKeys(functionStorage.id, functionStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  //   WEBSITE_RUN_FROM_PACKAGE: '1'
  //   WEBSITE_CONTENTSHARE: toLower(functionAppName)
  //   IDENTITY_ID: identityId
  //   SQL_DATABASE_NAME: sqlDatabaseName
  //   SQL_ENDPOINT: sqlEndpoint
  // }
}

resource functionAppAuthSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  parent: functionApp
  name: 'authsettings'
  properties: teamsFxConfiguration.authSettings.properties
  // properties: {
  //   enabled: true
  //   defaultProvider: 'AzureActiveDirectory'
  //   clientId: m365ClientId
  //   issuer: '${oauthAuthority}/v2.0'
  //   allowedAudiences: [
  //     m365ClientId
  //     m365ApplicationIdUri
  //   ]
  // }
}
