
# Demo

## Create Application Landing Zone Deployment Stack

``` bicep
New-AzSubscriptionDeploymentStack `
    -Name lz `
    -Location australiaeast `
    -TemplateFile ./deploymentStacks/src/orchestration/main.bicep `
    -TemplateParameterFile ./deploymentStacks/src/configuration/parameters.bicepparam `
    -ActionOnUnmanage detachAll `
    -DenySettingsMode denyDelete
```

## Get the Deployment Stack

``` bicep
Get-AzSubscriptionDeploymentStack -Name lz
```

## Get Deployment Stack Resources (Detailed)

``` bicep
(Get-AzSubscriptionDeploymentStack -Name lz).Resources
```

## Edit the Deployment Stack

- Go through the portal

## Delete Deployment Stack

``` bicep
Remove-AzSubscriptionDeploymentStack -Name Lz -ActionOnUnmanage deleteResources
```
