import { locPrefixes, resPrefixes } from './shared/namingConfig.bicep'

using '../orchestration/main.bicep'

param lzPrefix = 'sap'
param envPrefix = 'prd'
param tags = {
    environment: envPrefix
    applicationName: 'SAP Landing Zone'
    owner: 'Platform Team'
    criticality: 'Tier1'
    costCenter: '1234'
    contactEmail: 'stephen.tulp@outlook.com'
    dataClassification: 'Internal'
    iac: 'Bicep'
}
param budgets = [
    {
        amount: 500
        thresholds: [
            80
            100
        ]
        contactEmails: [
            'test@outlook.com'
        ]
    }
]
param actionGroupEmails = [
    'test@outlook.com'
]
param hubVirtualNetworkResourceId = '/subscriptions/8f8224ca-1a9c-46d1-9206-1cf2a7c51de8/resourceGroups/arg-syd-plat-conn-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-plat-conn-10.10.0.0_16'
param virtualNetworkPeeringEnabled = false
param allowHubVpnGatewayTransit = false
param nextHopIpAddress = '10.1.1.1'
param addressPrefixes = '10.15.0.0/24'
param subnets = [
    {
        name: 'app'
        addressPrefix: '10.15.0.0/27'
        networkSecurityGroupName: '${resPrefixes.networkSecurityGroup}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-app'
        securityRules: []
        routeTableName: '${resPrefixes.routeTable}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-app'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
    {
        name: 'db'
        addressPrefix: '10.15.0.32/27'
        networkSecurityGroupName: '${resPrefixes.networkSecurityGroup}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-db'
        securityRules: []
        routeTableName: '${resPrefixes.routeTable}-${locPrefixes.australiaEast}-${lzPrefix}-${envPrefix}-db'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
]
