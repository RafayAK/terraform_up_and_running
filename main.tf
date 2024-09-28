# This tells Terraform that you are going to be using AWS as your provider
# and that you want to deploy your infrastructure into the us-east-2
# region.

# General syntax for defining a resource in Terraform:
#
# resource "<PROVIDER>_<TYPE>" "<NAME>" {
# [CONFIG ...]
# }

# where <PROVIDER> is the name of the provider (e.g. aws, google, etc.)
# and <TYPE> is the type of resource (e.g. instance, bucket, etc.)
# and <NAME> is a name you choose to refer to this resource inside the Terraform configuration
# and [CONFIG ...] is a list of configuration settings for this resource

provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "example" {
    ami= "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"


    # add a name to the instance
    tags = {
        Name = "terraform-example"
    }
}

