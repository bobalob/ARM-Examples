Param(
    $deploymentPrefix = "deploy",
    $microsoftAccount = $true,
    $location = "North Europe"
)

# Ask user to Login to Account
$Account = Login-AzureRmAccount

# Ask user to Select the Subscription
$Subs = Get-AzureRmSubscription
Foreach ($Sub in $Subs) {
    $Sub
    $Answer = Read-Host "Use this subscription? [Y/N]"
    if ($Answer -eq "y") {
        $SubscriptionId = $Sub.SubscriptionId
        $Selected = Select-AzureRmSubscription -SubscriptionId $Sub.SubscriptionId
        Break
    }
}

if (!($SubscriptionId)) {
    Write-Warning "No Subscription was selected"
    Exit 1
}

# Use currently selected subscription Tenant and User Id to deploy the resources
if ($microsoftAccount) {
    #Nasty hack for microsoft accounts
    $aadAccount = Get-AzureRmAdUser | Where-Object {
        $_.UserPrincipalName -match ($Account.Context.Account.Id -Replace "@","_") |
        Select-Object -First 1
    }
} else {
    $aadAccount = Get-AzureRmAdUser -UserPrincipalName $Account.Context.Account.Id
}

# Set up parameters
$deploymentName = "$($deploymentPrefix)Deployment"
$resourceGroupName = "$($deploymentPrefix)Resources"
$parameters = @{
    "keyVaultPrefix"="keyvault";
    "storageAccountPrefix"="storage";
    "tennantId"=$Selected.Tenant.TenantId;
    "objectId"=$aadAccount.Id
}

# Deploy the prerequisite resources 
Write-Host "Create Resource Group: $($resourceGroupName)"
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
Write-Host "Start Deployment"
Write-Host ($parameters | Out-String)

New-AzureRmResourceGroupDeployment -Name $deploymentName `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile .\Resources\AzureDeploy.json `
    -TemplateParameterObject $parameters

