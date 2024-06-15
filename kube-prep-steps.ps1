#### Parameters

$keyvaultname = "kvextakscluster01"
$location = "uksouth"
$keyvaultrg = "kv-aks-rg01"
$sshkeysecret = "akssshpubkey"
$spnclientid = "07b176fd-b6d1-4de7-8ff4-9b8cf3eaae7e"
$clientidkvsecretname = "aks-spn"
$spnclientsecret = "koB8Q~ALX9lN-D-RhoGr-Ntb0b0SeQhWxnjNPcbE"
$spnkvsecretname = "spn-secret"
$spobjectID = "08eb713c-9c31-4aba-9a16-ba48e0b9b095"
$userobjectid = "1fe255d2-d546-475f-8ecb-b3af25931371"


# #### Create Key Vault

New-AzResourceGroup -Name $keyvaultrg -Location $location

New-AzKeyVault -Name $keyvaultname -ResourceGroupName $keyvaultrg -Location $location

Set-AzKeyVaultAccessPolicy -VaultName $keyvaultname -UserPrincipalName $userobjectid -PermissionsToSecrets get,set,delete,list

#### create an ssh key for setting up password-less login between agent nodes.

ssh-keygen  -f ~/.ssh/id_rsa_terraform


#### Add SSH Key in Azure Key vault secret

$pubkey = cat ~/.ssh/id_rsa_terraform.pub

$Secret = ConvertTo-SecureString -String $pubkey -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyvaultname -Name $sshkeysecret -SecretValue $Secret


#### Store service principal Client id in Azure KeyVault

$Secret = ConvertTo-SecureString -String $spnclientid -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyvaultname -Name $clientidkvsecretname -SecretValue $Secret


#### Store service principal Secret in Azure KeyVault

$Secret = ConvertTo-SecureString -String $spnclientsecret -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyvaultname -Name $spnkvsecretname -SecretValue $Secret


#### Provide Keyvault secret access to SPN using Keyvault access policy

Set-AzKeyVaultAccessPolicy -VaultName $keyvaultname -ServicePrincipalName $spnclientid -PermissionsToSecrets Get,Set
