#!/bin/bash

echo "Set the hostname for the VM. For example your companyname. No spaces, underscores, dashes or any special characters."
read -p 'VM Hostname: ' TF_VAR_vm_hostname
echo ""
echo "Set the admin username for the VM (must not be reserved words like admin, root, administrator)."
read -p 'Admin Username: ' TF_VAR_admin_username
echo ""
echo "Set the password for the VM (minimum lenght: 6, must contain uppercase, digit and special character)."
read -p 'Admin Password: ' TF_VAR_admin_password
echo ""
echo ""


# Generate random Inlets Server Authentication Token into environment variable
TF_VAR_inlets_authtoken=$(head -c 16 /dev/urandom | shasum | cut -d" " -f1)

# Read Service Principal details from az_client_credentials.json into environment variables
values=`cat az_client_credentials.json`

# for s in $(echo $values | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
#     echo $s
# done

ARM_SUBSCRIPTION_ID=`echo $values | jq -r '.subscriptionId'`
ARM_CLIENT_ID=`echo $values | jq -r '.clientId'`
ARM_CLIENT_SECRET=`echo $values | jq -r '.clientSecret'`
ARM_TENANT_ID=`echo $values | jq -r '.tenantId'`

if [ -f "terraform.tfvars" ]; then 
    rm -f terraform.tfvars
fi
echo "subscription_id   = \"$ARM_SUBSCRIPTION_ID\"" >> terraform.tfvars
echo "client_id         = \"$ARM_CLIENT_ID\"" >> terraform.tfvars
echo "client_secret     = \"$ARM_CLIENT_SECRET\"" >> terraform.tfvars
echo "tenant_id         = \"$ARM_TENANT_ID\"" >> terraform.tfvars

echo "vm_hostname       = \"$TF_VAR_vm_hostname\"" >> terraform.tfvars
echo "admin_username    = \"$TF_VAR_admin_username\"" >> terraform.tfvars
echo "admin_password    = \"$TF_VAR_admin_password\"" >> terraform.tfvars
echo "inlets_authtoken  = \"$TF_VAR_inlets_authtoken\"" >> terraform.tfvars

cat terraform.tfvars
