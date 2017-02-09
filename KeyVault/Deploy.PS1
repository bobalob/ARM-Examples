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

# Get the current logged in Azure AD user - This is the user who will have access to the key vault
if ($microsoftAccount) {
    #Nasty hack for microsoft accounts
    $aadAccount = Get-AzureRmAdUser | Where-Object {
        $_.UserPrincipalName -match "^$($Account.Context.Account.Id -Replace "@","_")"
    }
    if ($aadAccount.count -gt 1) {
        Write-Error "Not sure what to do, I found multiple users matching your account id"
        $aadAccount
        exit 1
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

