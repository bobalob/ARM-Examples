Param(
    $resourceGroupName="DemoResources",
    $storageAccountName="demostorages9612",
    $location = "North Europe",
    $scriptName = "dsc-webserver.ps1"
)
Set-Location $PSScriptRoot
$VMCredentials = Get-Credential -Message "Enter new virtual machine credentials"

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

# Publish the webserver.ps1 PowerShell DSC configuration
$dscUri = Publish-AzureRmVMDscConfiguration -ConfigurationPath ".\$($ScriptName)" `
    -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -force
Write-Host "$($scriptName) uploaded to $($dscUri)"

# Generate a SAS token
$sasToken = New-AzureStorageBlobSASToken -Container $dscUri.split("/")[3] `
    -Blob $dscUri.split("/")[-1] -Permission r `
    -ExpiryTime (Get-Date).AddHours(2.0) -Context $storageContext

# Deploy
Write-Host "Start Deployment"

$Deployment = New-AzureRmResourceGroupDeployment `
    -Name "$($ResourceGroupName)-Deployment" -ResourceGroupName $resourceGroupName `
    -TemplateFile .\AzureDeploy.json `
    -sasToken $sasToken -powerShellDscUri $dscUri `
    -storageAccountName $storageAccountName -adminUsername $VMCredentials.UserName `
    -adminPassword $VMCredentials.Password -powerShellDscConfigurationName "DSCWebServer" `
    -powerShellDscScriptName $ScriptName
