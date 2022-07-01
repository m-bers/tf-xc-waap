# F5 Distributed Cloud Terraform WAAP Lab

Welcome to my F5 Distributed Cloud lab! 

The purpose of this project is to, in a single terraform run, apply VPC/EC2 infrastructure in AWS with two applications: The OWASP Juice Shop and The F5 Arcadia Application, with Web Application and API Protection policies via F5 Distributed Cloud (F5 XC) that integrate existing knowledge of an API (in the form of a `swaggerfile`) and also tie into F5 XC's ability to [discover another API without](https://docs.cloud.f5.com/docs/how-to/app-security/apiep-discovery-control) an already specified definition.

## Getting Started

Clone this repo: 

```shell
$ git clone https://github.com/m-bers/tf-xc-waap.git
$ cd tf-xc-waap
```

## Terraform

Installation instructions for terraform for various operating systems are [here](https://learn.hashicorp.com/tutorials/terraform/install-cli). 

You will need a `terraform.tfvars` file in the root directory of the module (where you cloned this repo). An example is below:
```shell
# tf-xc-waap/terraform.tfvars.example

# AWS Resources
private_key_path     = "/home/ubuntu/.ssh/id_rsa"
public_key_path      = "/home/ubuntu/.ssh/id_rsa.pub"
ec2_user             = "ubuntu"
aws_credentials_path = "/Users/ubuntu/.aws/credentials"

# F5 Distributed Cloud namespace and tenant:
# Documentation -  https://docs.cloud.f5.com/docs/ves-concepts/core-concepts
xc_namespace = "some-namespace"
xc_tenant    = "some-tenant-djishwip"
xc_api_url   = "https://some-tenant.console.ves.volterra.io/api"

# F5 Distributed Cloud credentials:
# Documentation - https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials#generate-api-certificate
xc_p12_path = "/some/path/file.p12"
xc_password = "password"

# Application variables
juice_shop_swagger   = "swagger/juice-shop.yml"
juice_shop_fqdn      = "juice-shop.domain.com"
arcadia_fqdn         = "arcadia.domain.com"
```
## AWS 
This project also assumes the user has an AWS account. This spins up a pretty standard set of resources that should mostly be available via the free tier. To set up authentication, follow the steps under the [Shared Credentials File](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs#shared-credentials-file) section of the AWS terraform provider documentation.

## F5 Distributed Cloud
You will need an account with an Organization plan to access the F5 Distributed Cloud services used in this lab. If you have an account, you can set up authentication by following [this guide](https://registry.terraform.io/providers/volterraedge/volterra/latest/docs). If you don't have an account, fill out [the form here](https://www.f5.com/products/get-f5) and someone from F5 will reach out to you.

Once you are set up with an account, go ahead and [generate P12 API credentials](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials#generate-api-certificate) for terraform and download the .p12 file to your machine. Then set variable `xc_p12_path` in the `terraform.tfvars` file you created to the absolute path of the certificate. 

You also need to set the environment variable `VES_P12_PASSWORD` to the password you set for the .p12 in the F5 Distributed Cloud console (Here's how to set environment variables for [Mac](https://support.apple.com/guide/terminal/use-environment-variables-apd382cc5fa-4f58-4449-b20a-41c53c006f8f/mac), [Windows](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1), and [Linux](https://www.digitalocean.com/community/tutorials/how-to-read-and-set-environmental-and-shell-variables-on-linux)).

You will also need to set up a delegated domain. I am using an existing domain in the F5 tenant, so domain delegation is outside the scope of this lab. However, there are instructions to set up your own delegated domain [here](https://docs.cloud.f5.com/docs/how-to/app-networking/domain-delegation).

# Running the module

After you have terraform installed and have AWS and F5 XC credentials set up, you can deploy in just two steps.

```shell
$ terraform init
$ terraform apply 
```

If everything looks good, type "yes" at the prompt and check out your deployed resources in the F5 Distributed Cloud console at your tenant URL!