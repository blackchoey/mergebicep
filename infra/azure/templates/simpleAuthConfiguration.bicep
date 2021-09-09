param simpleAuthWebAppName string
param simpelAuthPackageUri string
@secure()
param teamsFxConfiguration object

resource simpleAuthDeploy 'Microsoft.Web/sites/extensions@2021-01-15' = {
  name: '${simpleAuthWebAppName}/MSDeploy'
  properties: {
    packageUri: simpelAuthPackageUri
  }
}

resource simpleAuthWebAppSettings 'Microsoft.Web/sites/config@2018-02-01' = {
  dependsOn: [
    simpleAuthDeploy
  ]
  name: '${simpleAuthWebAppName}/appsettings'
  properties: teamsFxConfiguration.appSettings.properties
  // properties: {
  //   AAD_METADATA_ADDRESS: aadMetadataAddress
  //   ALLOWED_APP_IDS: authorizedClientApplicationIds
  //   IDENTIFIER_URI: m365ApplicationIdUri
  //   CLIENT_ID: m365ClientId
  //   CLIENT_SECRET: m365ClientSecret
  //   OAUTH_AUTHORITY: oauthAuthority
  //   TAB_APP_ENDPOINT: frontendHostingStorageEndpoint
  // }
}


