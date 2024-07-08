@export()
var locPrefixes = {
  australiaEast: 'syd'
  australiaCentral: 'auc'
  australiaCentral2: 'auc2'
  australiaSoutheast: 'mel'
}

@export()
var delimeters = {
  dash: '-'
  none: ''
}

@export()
var resPrefixes = {
  resourceGroup: 'arg'
  networkSecurityGroup: 'nsg'
  virtualNetwork: 'vnt'
  routeTable: 'udr'
  keyVault: 'akv'
  logAnalyticsWorkspace: 'law'
  appInsights: 'aai'
  storage: 'sta'
  userAssignedIdentity: 'uai'
  serviceBus: 'sb'
  appServiceEnvironment: 'ase'
  apiManagement: 'apim'
  appServicePlan: 'asp'
  containerRegistry: 'acr'
}

@export()
var commonResourceGroupNames = [
  'alertsRG'
  'networkWatcherRG'
  'ascExportRG'
]

@export()
var customNames = {
  networkRg: ''
  virtualNetwork: ''
  actionGroup: ''
  actionGroupShort: ''
}
