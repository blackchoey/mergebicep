param functionServerfarmsName string
param functionAppName string
param functionStorageName string
@secure()
param teamsFxConfiguration object

resource functionServerfarms 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: functionServerfarmsName
  kind: 'functionapp'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
  }
}

var a = json(loadTextContent('./funcConfig.json'))

resource functionApp2 'Microsoft.Web/sites@2020-06-01' = a

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: functionAppName
  kind: 'functionapp'
  location: resourceGroup().location
  properties: {
    serverFarmId: functionServerfarms.id
  }
  // identity: {
  //   type: 'UserAssigned'
  //   userAssignedIdentities: {
  //     '${identityName}':{}
  //   }
  // }
  identity: teamsFxConfiguration.identity
}

resource functionStorage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: functionStorageName
  kind: 'StorageV2'
  location: resourceGroup().location
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  sku: {
    name: 'Standard_LRS'
  }
}

output appServicePlanName string = functionServerfarms.name
output functionEndpoint string = functionApp.properties.hostNames[0]
output storageAccountName string = functionStorage.name
output appName string = functionAppName
