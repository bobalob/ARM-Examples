Param(
    $resourceGroupName="DemoResources",
    $storageAccountName="demostorages0371",
    $location = "North Europe"
)
Set-Location $PSScriptRoot

# Ask user to Login to Account
if (!($Account)) {$Account = Login-AzureRmAccount}

$storageOk = Get-AzureRmStorageAccountNameAvailability $storageAccountName
if (!($storageOk.NameAvailable)) {
    Write-Error "Storage Account name not valid, $($storageOk.Message)"
    break
}

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

# Create the Resource Group
Write-Host "Create Resource Group: $($resourceGroupName)"
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Create The Storage Account & Container
Write-Host "Create Storage Account: $($storageAccountName)"
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
     -Name $storageAccountName -SkuName "Standard_LRS" -Kind "Storage" -Location $location
Start-Sleep 10

$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName `
    -StorageAccountKey $Keys[0].Value
$container = New-AzureStorageContainer -Context $storageContext -Name "templates"

# Upload the NetworkLinkedTemplate.json
$blob = Set-AzureStorageBlobContent -Context $storageContext -Container "templates" `
    -File .\NetworkLinkedTemplate.json
Write-Host "NetworkLinkedTemplate.json uploaded to $($blob.ICloudBlob.Uri.AbsoluteUri)"

# Generate a SAS token
$sasToken = New-AzureStorageBlobSASToken -Container "templates" `
    -Blob "NetworkLinkedTemplate.json" -Permission r `
    -ExpiryTime (Get-Date).AddHours(2.0) -Context $storageContext

# Deploy
Write-Host "Start Deployment"

$Deployment = New-AzureRmResourceGroupDeployment `
    -Name "$($ResourceGroupName)-Deployment" -ResourceGroupName $resourceGroupName `
    -TemplateFile .\AzureDeploy.json `
    -sasToken $sasToken -linkedTemplateUri $blob.ICloudBlob.Uri.AbsoluteUri
