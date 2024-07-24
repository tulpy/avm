targetScope = 'resourceGroup'

metadata name = 'Test and Validation Deployment'
metadata description = 'Test and Validation of the vnetPeering Module.'

module testDeployment '../vnetPeering.bicep' = {
  name: take('testDeployment-${guid(deployment().name)}', 64)
  params: {
    name: 'vnetPeering'
    destinationVirtualNetworkId: '/subscriptions/8f8224ca-1a9c-46d1-9206-1cf2a7c51de8/resourceGroups/arg-syd-plat-conn-network/providers/Microsoft.Network/virtualNetworks/vnt-syd-plat-conn-10.10.0.0_16'
    sourceVirtualNetworkName: 'vnet1'
    destinationVirtualNetworkName: 'vnet2'
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}
