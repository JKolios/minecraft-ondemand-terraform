# minecraft-ondemand-terraform

Terraform implementation of https://github.com/doctorray117/minecraft-ondemand 

## Prerequisites
* Terraform 1.0 (Terraform 0.13 and later likely to work, untested). This README assumes you have basic knowledge of Terraform.
* A domain under your control, DNS servers must be changeable
* An AWS account that you have admin access over
* Optionally, an email address to receive "Server started" and "Server Stopped" notifications

## Running

Set up authentication with your AWS account using your preferred method from this doc: [Authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) Using the *Static Credentials* method requires changing the `provider` definition in `terraform/provider.tf`.

From the `terraform` directory, run `terraform plan` and `terraform apply`. You have to provide values to the following vars:
* `aws_region`: The AWS region to deploy the Minecraft server in
* `domain_name` : The domain your server will run under
* `domain_name` : The domain your server will run under
* `sns_notification_email` : The email address where you will receive notifications
You can input these from the command line or [through a tfvars file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files).

Note the `hosted_zone_nameservers` output from `terraform apply`. Apply these DNS server addresses to your domain.

Your `sns_notification_email` should have received a confirmation email from AWS. Follow the link in it to enable email notifications.

If everything worked correctly, trying to resolve `minecraft.${DOMAIN_NAME}` should start the server. This might take 5-10 minutes on the first run. The server should then be reachable at `minecraft.${DOMAIN_NAME}`.

## Caveats

* Limited testing done so far.
* Twilio SMS notifications are not supported.
* At this time `terraform destroy` is not guaranteed to work cleanly in a reliable manner.
