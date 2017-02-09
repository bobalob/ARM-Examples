# KeyVault
ARM Example files for Secure KeyVault access to Storage Account. Avoids having to have the json templates and vm provisioning scripts stored on a public URL.

    Deploy.PS1

Creates the neccessary key and storage resources, Uploads the example deployments and runs them with a key

### Resources folder
This will deploy the KeyVault and private Storage Account that will hold the actual deployment scripts

### Example folder
This will deploy a test resource with a reference to a script in the private Storage Account

