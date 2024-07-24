targetScope = 'resourceGroup'

metadata name = 'Test and Validation Deployment'
metadata description = 'Test and Validation of the spokeNetworking Module.'

module testDeployment '../spokeNetworking.bicep' = {
  name: take('testDeployment-${guid(deployment().name)}', 64)
  params: {
    spokeNetworkName: 'vnt-01'
    location: 'australiaeast'
    tags: {
      environment: 'envPrefix'
      applicationName: 'SAP Landing Zone'
      owner: 'Platform Team'
      criticality: 'Tier1'
      costCenter: '1234'
      contactEmail: 'stephen.tulp@outlook.com'
      dataClassification: 'Internal'
      iac: 'Bicep'
    }
    addressPrefixes: '10.15.0.0/24'
    ddosProtectionPlanId: ''
    dnsServerIps: []
    subnets: [
      {
        name: 'app'
        addressPrefix: '10.15.0.0/27'
        networkSecurityGroupName: 'nsg-syd-sap-prd-app'
        securityRules: []
        routeTableName: 'udr-syd-sap-prd-app'
        routes: []
        serviceEndpoints: []
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
    }
    ]
    disableBgpRoutePropagation: false
    nextHopIpAddress: '10.1.1.1'
  }
}
