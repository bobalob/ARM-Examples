# PowerShell DSC Example
ARM Example files to show the use of a PowerShell DSC Extension. Based on the SAS-Token-Example but taken one step further in order to deploy a PowerShell DSC extension.

    Deploy.PS1

* Creates a Resource Group and Storage Account in PowerShell. 
* Publishes webserver.ps1 DSC configuration file.
* Generates a SAS Key for the DSC extension file.
* Deploys AzureDeploy.json with a SAS token and the webserver.ps1 URI as parameters.

### AzureDeploy.json
Deploys a virtual machine and associated resources with a PowerShell DSC extension.
