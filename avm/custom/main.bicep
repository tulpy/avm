import * as shared from './configuration/shared/shared.conf.bicep'

targetScope = 'subscription'

metadata name = 'ALZ Bicep - LZ Module'
metadata description = 'Module for the Azure Landing Zone deployment.'
metadata version = '1.0.0'
metadata author = 'Insight APAC Platform Engineering'

@description('Optional. The Azure Region to deploy the resources into.')
param location string = deployment().location

@maxLength(10)
@description('Required. Specifies the Landing Zone prefix for the deployment and Azure resources. This is the function of the Landing Zone AIS, SAP, AVD etc.')
param lzPrefix string

@allowed([
  'dev'
  'tst'
  'prd'
  'sbx'
])
@description('Required. Specifies the environment prefix for the deployment.')
param envPrefix string

@description('Optional. Boolean to use custom naming for resources.')
param useCustomNaming bool = false

@description('Optional. An object of tag key & value pairs to be appended to the Azure Subscription and Resource Group.')
param tags object?

@description('Optional. Whether to create a virtual network or not.')
param virtualNetworkEnabled bool = true

@description('Optional. The address space of the Virtual Network that will be created by this module, supplied as multiple CIDR blocks in an array, e.g. `["10.0.0.0/16","172.16.0.0/12"]`.')
param addressPrefixes string = ''

@description('Optional. IP Address of the centralised firewall if used.')
param nextHopIpAddress string

@description('Optional. Specifies the Subnets array - name, address space, configuration.')
param subnets array = []

@description('Optional. Array of DNS Server IP addresses for the Virtual Network.')
param dnsServerIps array = []

@description('Optional. Switch which allows BGP Propagation to be disabled on the route tables.')
param disableBgpRoutePropagation bool = true

@description('Optional. ResourceId of the DdosProtectionPlan which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

@description('Optional. Whether to enable peering/connection with the supplied hub Virtual Network or Virtual WAN Virtual Hub.')
param virtualNetworkPeeringEnabled bool = true

@description('Optional. The resource ID of the Virtual Network or Virtual WAN Hub in the hub to which the created Virtual Network, by this module, will be peered/connected to via Virtual Network Peering or a Virtual WAN Virtual Hub Connection.')
param hubVirtualNetworkResourceId string = ''

@description('Optional. Switch to enable/disable forwarded Traffic from outside spoke network.')
param allowSpokeForwardedTraffic bool = true

@description('Optional. Switch to enable/disable VPN Gateway Transit for the hub network peering.')
param allowHubVpnGatewayTransit bool = true

@description('Optional. Specifies the Azure Budget details for the Landing Zone.')
param budgets array = []

@description('Optional. Whether to create a Landing Zone Action Group or not.')
param actionGroupEnabled bool = true

@description('Optional. Specifies an array of email addresses for the Landing Zone action group.')
param actionGroupEmails array = []

@description('Optional. The JSON payload for the name prefixes, if wanting to override that in the ../configuration/shared/ folder.')
param namePrefixesPayload object = {}

@description('Optional. The JSON payload for the location prefixes, if wanting to override that in the ../configuration/shared/ folder.')
param locationPrefixesPayload object = {}

// Variables
var namePrefixes = !empty(namePrefixesPayload) ? namePrefixesPayload : shared.resPrefixes
var locationPrefixes = !empty(locationPrefixesPayload) ? locationPrefixesPayload : shared.locPrefixes
var argPrefix = toLower('${namePrefixes.resourceGroup}${shared.delimeters.dash}${locationPrefixes[location]}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}')
var vntPrefix = toLower('${namePrefixes.virtualNetwork}${shared.delimeters.dash}${locationPrefixes[location]}${shared.delimeters.dash}${lzPrefix}${shared.delimeters.dash}${envPrefix}')
var vNetAddressSpace = replace(addressPrefixes, '/', '_')

// Check hubVirtualNetworkResourceId to see if it's a virtual WAN connection instead of normal virtual network peering
var hubVirtualNetworkResourceIdChecked = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? hubVirtualNetworkResourceId
  : '')

var hubVirtualNetworkName = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? split(hubVirtualNetworkResourceId, '/')[8]
  : '')
var hubVirtualNetworkSubscriptionId = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? split(hubVirtualNetworkResourceId, '/')[2]
  : '')
var hubVirtualNetworkResourceGroup = (!empty(hubVirtualNetworkResourceId) && contains(
    hubVirtualNetworkResourceId,
    '/providers/Microsoft.Network/virtualNetworks/'
  )
  ? split(hubVirtualNetworkResourceId, '/')[4]
  : '')

var resourceGroups = {
  network: useCustomNaming && !empty(shared.customNames.networkRg)
    ? shared.customNames.networkRg
    : '${argPrefix}${shared.delimeters.dash}network'
}

var resourceNames = {
  virtualNetwork: useCustomNaming && !empty(shared.customNames.virtualNetwork)
    ? shared.customNames.virtualNetwork
    : '${vntPrefix}${shared.delimeters.dash}${vNetAddressSpace}'
  actionGroup: useCustomNaming && !empty(shared.customNames.actionGroup)
    ? shared.customNames.actionGroup
    : '${lzPrefix}${envPrefix}ActionGroup'
  actionGroupShort: useCustomNaming && !empty(shared.customNames.actionGroupShort)
    ? shared.customNames.actionGroupShort
    : '${lzPrefix}${envPrefix}AG'
}

// Resource: Subscription Tags
resource tag 'Microsoft.Resources/tags@2021-04-01' = {
  name: 'default'
  properties: {
    tags: tags
  }
}

// Module: Subscription Budget
module budget 'br/public:avm/res/consumption/budget:0.3.3' = [
  for (bg, index) in budgets: if (!empty(budgets)) {
    name: take('subBudget-${guid(deployment().name)}-${index}', 64)
    params: {
      name: 'budget'
      location: location
      amount: bg.amount
      thresholds: bg.thresholds
      contactEmails: bg.contactEmails
    }
  }
]

// Module: Resource Groups (Common)
module sharedResourceGroups 'br/public:avm/res/resources/resource-group:0.2.4' = [
  for commonResourceGroup in shared.commonResourceGroupNames: {
    name: take('sharedResourceGroups-${commonResourceGroup}', 64)
    params: {
      name: commonResourceGroup
      location: location
      tags: tags
    }
  }
]

// Module: Action Group
module actionGroup 'br/public:avm-res-insights-actiongroup:0.1.1' = if (actionGroupEnabled && !empty(actionGroupEmails)) {
  name: take('actionGroup-${guid(deployment().name)}', 64)
  scope: resourceGroup('alertsRG')
  dependsOn: [
    sharedResourceGroups
  ]
  params: {
    location: 'Global'
    name: resourceNames.actionGroup
    groupShortName: resourceNames.actionGroupShort
    emailReceivers: [
      for email in actionGroupEmails: {
        emailAddress: email
        name: split(email, '@')[0]
        useCommonAlertSchema: true
      }
    ]
  }
}

// Module: Resource Groups (Network)
module resourceGroupForNetwork 'br/public:avm/res/resources/resource-group:0.2.4' = if (virtualNetworkEnabled) {
  name: take('resourceGroupForNetwork-${guid(deployment().name)}', 64)
  params: {
    name: resourceGroups.network
    location: location
    tags: tags
  }
}

// Module: Network Watcher
module networkWatcher 'br/public:avm/res/network/network-watcher:0.1.1' = if (virtualNetworkEnabled) {
  name: take('networkWatcher-${guid(deployment().name)}', 64)
  scope: resourceGroup('networkWatcherRG')
  dependsOn: [
    sharedResourceGroups
  ]
  params: {
    location: location
    tags: tags
  }
}

// Module: Spoke Networking
module spokeNetworking './modules/spokeNetworking/spokeNetworking.bicep' = if (virtualNetworkEnabled && !empty(addressPrefixes)) {
  scope: resourceGroup(resourceGroups.network)
  name: take('spokeNetworking-${guid(deployment().name)}', 64)
  dependsOn: [
    resourceGroupForNetwork
  ]
  params: {
    spokeNetworkName: resourceNames.virtualNetwork
    addressPrefixes: addressPrefixes
    ddosProtectionPlanId: ddosProtectionPlanId
    dnsServerIps: dnsServerIps
    nextHopIpAddress: nextHopIpAddress
    subnets: subnets
    disableBgpRoutePropagation: disableBgpRoutePropagation
    tags: tags
    location: location
  }
}

// Module: Virtual Network Peering (Hub to Spoke)
module hubPeeringToSpoke './modules/vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(hubVirtualNetworkSubscriptionId, hubVirtualNetworkResourceGroup)
  name: take('hubPeeringToSpoke-${guid(deployment().name)}', 64)
  params: {
    sourceVirtualNetworkName: hubVirtualNetworkName
    destinationVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkName : '')
    destinationVirtualNetworkId: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkId : '')
    allowForwardedTraffic: allowSpokeForwardedTraffic
    allowGatewayTransit: allowHubVpnGatewayTransit
  }
}

// Module: Virtual Network Peering (Spoke to Hub)
module spokePeeringToHub './modules/vnetPeering/vnetPeering.bicep' = if (virtualNetworkEnabled && virtualNetworkPeeringEnabled && !empty(hubVirtualNetworkResourceIdChecked) && !empty(addressPrefixes) && !empty(hubVirtualNetworkResourceGroup) && !empty(hubVirtualNetworkSubscriptionId)) {
  scope: resourceGroup(resourceGroups.network)
  name: take('spokePeeringToHub-${guid(deployment().name)}', 64)
  params: {
    sourceVirtualNetworkName: (!empty(hubVirtualNetworkName) ? spokeNetworking.outputs.spokeVirtualNetworkName : '')
    destinationVirtualNetworkName: hubVirtualNetworkName
    destinationVirtualNetworkId: hubVirtualNetworkResourceId
    allowForwardedTraffic: allowSpokeForwardedTraffic
    useRemoteGateways: allowHubVpnGatewayTransit
  }
}
