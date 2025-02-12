env=play

# init 
terraform -chdir=bootstrap fmt
terraform -chdir=environments/${env} fmt
terraform -chdir=bootstrap init -backend-config=../environments/${env}/tf-backend-${env}.conf -backend-config="prefix=$env-cni"

# tf plan
terraform -chdir=bootstrap plan -var-file=../environments/${env}/terraform-${env}.tfvars  -out=../../${env}-planfile -input=false -compact-warnings
terraform -chdir=bootstrap validate

# tf apply 
terraform -chdir=bootstrap apply -input=false "../../${env}-planfile" -compact-warnings
