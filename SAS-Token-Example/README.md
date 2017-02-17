# SAS-Token-Example
ARM Example files to show the use of a SAS Key to access a Storage Account for linked template access

    Deploy.PS1

* Creates a Resource Group and Storage Account in PowerShell. 
* Uploads the NetworkLinkedTemplate.json file.
* Generates a SAS Key for NetworkLinkedTemplate.json file.
* Deploys AzureDeploy.json with a SAS token and the NetworkLinkedTemplate.json URI as parameters.

### AzureDeploy.json
Deploys a single linked template resource defined by parameters.

### NetworkLinkedTemplate.json
This will deploy a test resource (VNET)
