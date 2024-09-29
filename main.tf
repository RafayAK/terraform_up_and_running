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



# create a varibale to store server port
variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type = number
    default = 8080
  
}


resource "aws_instance" "example" {
    ami= "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"

    # security group is a list of security group IDs to associate with the instance
    # we defined the security group below
    vpc_security_group_ids = [ aws_security_group.instance.id ]


    # The <<EOF syntax is a heredoc in Terraform. It allows you to write a multi-line string
    user_data = <<-EOF
                #!/bin/bash 
                echo "Hello, World" > index.html
                python3 -m http.server 8080 &
                EOF

    # This tells Terraform to replace the instance if the user data changes
    # Terraform will destroy the existing instance and create a new one
    # The deault beahaivor is to update the instance in place
    # 
    # Since User Data runs only on the very first boot, and your
    # original instance already went through that boot process, you need to
    # force the creation of a new instance to ensure your new User Data
    # script actually gets executed.
    user_data_replace_on_change = true

    # add a name to the instance
    tags = {
        Name = "terraform-example"
    }
}


# Create a security group
# By default, all inbound and outbout traffic is blocked from an EC2 instance.
# To allow traffic to and from the instance on port 8080, you need to create a security group

# creating a security group is not enough. You also need to tell the EC2 instance to use this security group
  
resource "aws_security_group" "instance" {
  name        = "terraform-example-instance"
  description = "Allow inbound traffic on port ${var.server_port}" # this is a string interpolation for varibale server_port
  tags = {
    Name = "allow-8080-instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ingress-8080" {
  security_group_id = aws_security_group.instance.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.server_port
  ip_protocol = "tcp"
  to_port     = var.server_port
}


# define an output for the public IP address of the instance
output "public_ip" {
    value = aws_instance.example.public_ip
    description = "The public IP address of the web server"
  
}