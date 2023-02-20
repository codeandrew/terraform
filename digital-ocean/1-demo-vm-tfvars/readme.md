# Terraform using vars


terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"


## Scripted 

```bash
#!/bin/bash

list=(development.tfvars integration.tfvars staging.tfvars production.tfvars)

for file in "${list[@]}"
do
  terraform plan -var-file="$file"
  terraform apply -var-file="$file"
done
```