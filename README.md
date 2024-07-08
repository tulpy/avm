
Create Deployment Stack

``` bicep
New-AzSubscriptionDeploymentStack `
    -Name lz `
    -Location australiaeast `
    -TemplateFile ./deploymentStacks/src/orchestration/main.bicep `
    -TemplateParameterFile ./deploymentStacks/src/configuration/parameters.bicepparam `
    -ActionOnUnmanage detachAll `
    -DenySettingsMode none

Get-AzSubscriptionDeploymentStack `
  -Name "lz"

(Get-AzSubscriptionDeploymentStack -Name "lz").Resources

Remove-AzSubscriptionDeploymentStack -Name Lz -ActionOnUnmanage deleteAll

```
