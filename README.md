# Aplazame DevOps
This folder contains a set of Terraform code. 

To try any example, clone this repository, set Access an Secret key and run the following commands
from within the example's directory:

```shell
$ export env=dev
$ terraform workspace select ${env}
$ terraform apply -var-file="environments/${env}/${env}.tfvars"
```
