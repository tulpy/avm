import * as shared from '../../configuration/shared/shared.conf.bicep'

targetScope = 'resourceGroup'

metadata name = 'ALZ Bicep - Spoke Networking module'
metadata description = 'Deploy the Spoke Networking Module for Azure Landing Zones'
metadata version = '1.1.0'
metadata author = 'Insight APAC Platform Engineering'

// Parameters
@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object?

@description('Required. The name of the Virtual Network (vNet).')
param spokeNetworkName string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes string

@description('Optional. The DdosProtectionPlan Id which will be applied to the Virtual Network.')
param ddosProtectionPlanId string = ''

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServerIps array = []

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

@description('Optional. Switch to disable BGP route propagation.')
param disableBgpRoutePropagation bool = false

@description('Optional. The IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.')
param nextHopIpAddress string = ''

// Resource: Spoke Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: spokeNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixes
      ]
    }
    enableDdosProtection: (!empty(ddosProtectionPlanId) ? true : false)
    ddosProtectionPlan: (!empty(ddosProtectionPlanId) ? true : false)
      ? {
          id: ddosProtectionPlanId
        }
      : null
    dhcpOptions: (!empty(dnsServerIps) ? true : false)
      ? {
          dnsServers: dnsServerIps
        }
      : null
    subnets: [
      for (subnet, index) in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          addressPrefixes: []
          networkSecurityGroup: (!empty(subnet.networkSecurityGroupName))
            ? {
                id: resourceId('Microsoft.Network/networkSecurityGroups', '${subnet.networkSecurityGroupName}')
              }
            : null
          routeTable: (!empty(nextHopIpAddress) && !empty(subnet.routeTableName))
            ? {
                id: resourceId('Microsoft.Network/routeTables', '${subnet.routeTableName}')
              }
            : null
          delegations: subnet.delegations
          privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
          serviceEndpointPolicies: []
          serviceEndpoints: subnet.serviceEndpoints
        }
      }
    ]
  }
  dependsOn: [
    routeTable
    networkSecurityGroup
  ]
}

// Module: Route Table
module routeTable 'br/public:avm/res/network/route-table:0.2.2' = [
  for (subnet, i) in subnets: if (!empty(nextHopIpAddress) && !empty(subnet.routeTableName)) {
    name: 'routeTable-${i}'
    params: {
      name: subnet.routeTableName
      location: location
      tags: tags
      routes: concat(shared.routes, subnet.routes)
      disableBgpRoutePropagation: disableBgpRoutePropagation
    }
  }
]

// Module: Network Security Group
module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.1.3' = [
  for (subnet, i) in subnets: if (!empty(subnet.networkSecurityGroupName)) {
    name: 'nsg-${i}'
    params: {
      name: subnet.networkSecurityGroupName
      location: location
      tags: tags
      securityRules: concat(shared.sharedNSGrulesInbound, shared.sharedNSGrulesOutbound, subnet.securityRules)
    }
  }
]

// Outputs
@description('The Virtual Network Name.')
output spokeVirtualNetworkName string = virtualNetwork.name

@description('The Virtual Network Resource Id.')
output spokeVirtualNetworkId string = virtualNetwork.id

@description('The Subnets of the Spoke Virtual Network.')
output spokeSubnets array = [
  for i in range(0, length(subnets)): {
    name: virtualNetwork.properties.subnets[i].name
    id: virtualNetwork.properties.subnets[i].id
  }
]

@description('An array of Route Tables.')
output routeTable array = [
  for (subnet, i) in subnets: {
    name: !empty(nextHopIpAddress) && !empty(subnet.routeTableName) ? routeTable[i].outputs.name : ''
    id: !empty(nextHopIpAddress) && !empty(subnet.routeTableName) ? routeTable[i].outputs.resourceId : ''
  }
]

@description('An array of Network Security Groups.')
output networkSecurityGroup array = [
  for (subnet, i) in subnets: {
    name: !empty(subnet.networkSecurityGroupName) ? networkSecurityGroup[i].outputs.name : ''
    id: !empty(subnet.networkSecurityGroupName) ? networkSecurityGroup[i].outputs.name : ''
  }
]
