
# Demo

## Create Application Landing Zone Deployment Stack

``` bicep
New-AzSubscriptionDeploymentStack `
    -Name lz `
    -Location australiaeast `
    -TemplateFile ./deploymentStacks/src/orchestration/main.bicep `
    -TemplateParameterFile ./deploymentStacks/src/configuration/parameters.bicepparam `
    -ActionOnUnmanage deleteResources `
    -DenySettingsMode denyDelete `
    -Verbose
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

- Go through the portal and show the settings and UX
- Try to delete a resource (Show Owner permissions)'
- Show Deny Assignments on the Network RG

## Update Application Landing Zone Deployment Stack

- Delete a subnet in the parameter file

``` bicep
New-AzSubscriptionDeploymentStack `
    -Name lz `
    -Location australiaeast `
    -TemplateFile ./deploymentStacks/src/orchestration/main.bicep `
    -TemplateParameterFile ./deploymentStacks/src/configuration/parameters.bicepparam `
    -ActionOnUnmanage deleteResources `
    -DenySettingsMode denyDelete `
    -Verbose
```

## Delete Deployment Stack

``` bicep
Remove-AzSubscriptionDeploymentStack -Name Lz -ActionOnUnmanage deleteResources
```
