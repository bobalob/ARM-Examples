# KeyVault
ARM Example files to show the use of a SAS Key to access a Storage Account for linked template access

    Deploy.PS1

* Creates a Resource Group and Storage Account in PowerShell. 
* Uploads the NetworkLinkedTemplate.json file.
* Generates a SAS Key for NetworkLinkedTemplate.json file.
* Deploys AzureDeploy.json

### AzureDeploy.json
Deploys a single linked template resource that was uploaded by the Deploy.PS1

### NetworkLinkedTemplate.json
This will deploy a test resource (VNET)
