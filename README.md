Always export this first:

```bash
export AWS_PROFILE=terraform-book
```

The general
syntax for creating a resource in Terraform is as follows:

```
    resource "<PROVIDER>_<TYPE>" "<NAME>" {
    [CONFIG ...]
    }
```

where:

- `<PROVIDER>` is the name of the provider (e.g. aws, google, etc.)
- `<TYPE>` is the type of resource (e.g. instance, bucket, etc.)
- `<NAME>` is a name you choose to refer to this resource inside the Terraform configuration
- `[CONFIG ...]` is a list of configuration settings for this resource


The terraform binary contains the basic functionality for Terraform, but
it does not come with the code for any of the providers (e.g., the AWS
Provider, Azure provider, GCP provider, etc.), so when you’re first starting
to use Terraform, you need to run `terraform init` to tell Terraform to
scan the code, figure out which providers you’re using, and download the
code for them. By default, the provider code will be downloaded into a
`.terraform` folder, which is Terraform’s scratch directory (__you may want to add it to .gitignore__)


You’ll notice that the apply command shows you __the same plan__ output and asks you to confirm whether you actually want to proceed with this plan.
So, while plan is available as a separate command, it’s mainly useful for quick sanity checks and during code reviews

The output of the `plan` command is similar to the output of the `diff` command that is part of Unix, Linux, and `git`:
- anything with a plus sign (`+`) will be created, 
- anything with a minus sign (`–`) will be deleted, and 
- anything with a tilde sign (`~`) will be modified in place.


## PORT NUMBERS
The reason this example uses port `8080`, rather than the default HTTP port `80`, is that
listening on any port less than `1024` requires root user privileges. This is a security risk
since any attacker who manages to compromise your server would get root privileges, too.


Therefore, it’s a best practice to run your web server with a non-root user that has
limited permissions. That means you have to listen on higher-numbered ports, but as
you’ll see later in this chapter, you can configure a load balancer to listen on port `80` and
route traffic to the high-numbered ports on your server(s).


----
Big list of http static server one-liners (https://gist.github.com/willurd/5720255)


To access the ID of the security group resource, you are going to need to use a resource attribute
reference, which uses the following syntax: `<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>`. 
Where the `PROVIDER` is the name of the provider (e.g., `aws`), `TYPE` is the type of resource (e.g., `security_group`), `NAME` is the name of that resource
(e.g., the security group is named "instance"), and `ATTRIBUTE` is either one of the arguments of that resource (e.g., name) or one of the attributes exported by the resource (you can find the list of available attributes in the documentation for each resource). The security group exports an attribute called id, so the expression to reference it will look like this:

    aws_security_group.instance.id


When you add a reference from one resource to another, you create an implicit dependency. Terraform parses these dependencies, builds a dependency graph from them, and uses that to automatically determine in which order it should create resources. For example, if you were deploying this code from scratch, Terraform would know that it needs to create the security group before the EC2 Instance, because the EC2 Instance references the ID of the security group. You can even get Terraform to show
you the dependency graph by running the graph command:

```bash
╰─ terraform graph
digraph G {
  rankdir = "RL";
  node [shape = rect, fontname = "sans-serif"];
  "aws_instance.example" [label="aws_instance.example"];
  "aws_security_group.instance" [label="aws_security_group.instance"];
  "aws_vpc_security_group_ingress_rule.allow-ingress-8080" [label="aws_vpc_security_group_ingress_rule.allow-ingress-8080"];
  "aws_instance.example" -> "aws_security_group.instance";
  "aws_vpc_security_group_ingress_rule.allow-ingress-8080" -> "aws_security_group.instance";
}
```

---

## VARIABLES

To allow you to make your code more DRY and more configurable, Terraform allows you to define input variables. Here’s the syntax for
declaring a variable:

```
variable "NAME" {
[CONFIG ...]
}
```

The body of the variable declaration can contain the following optional parameters:

- __description__

    It’s always a good idea to use this parameter to document how a
    variable is used. Your teammates will be able to see this description not
    only while reading the code but also when running the plan or apply
    commands (you’ll see an example of this shortly).

- __default__

    There are a number of ways to provide a value for the variable,
    including passing it in at the command line (using the -var option), via
    a file (using the `-var-file` option), or via an environment variable
    (Terraform looks for environment variables of the name
    `TF_VAR_<variable_name>`). If no value is passed in, the variable
    will fall back to this default value. If there is no default value, Terraform
    will interactively prompt the user for one.

- __type__

    This allows you to enforce type constraints on the variables a user
    passes in. Terraform supports a number of type constraints, including
    string, number, bool, list, map, set, object, tuple, and
    any. It’s always a good idea to define a type constraint to catch simple
    errors. If you don’t specify a type, Terraform assumes the type is any.

- __validation__

    This allows you to define custom validation rules for the input variable
    that go beyond basic type checks, such as enforcing minimum or
    maximum values on a number.

- __sensitive__

    If you set this parameter to true on an input variable, Terraform will
    not log it when you run plan or apply. You should use this on any
    secrets you pass into your Terraform code via variables: e.g., passwords,
    API keys, etc.


Example:

```json
# a number var

variable "number_example" {
    description = "An example of a number variable in Terraform"
    type = number
    default = 42
}

# a list var
variable "list_example" {
    description = "An example of a list in Terraform"
    type = list
    default = ["a", "b", "c"]
}

# a list of numbers

variable "list_numeric_example" {
    description = "An example of a numeric list in Terraform"
    type = list(number)
    default = [1, 2, 3]
}

# a map with strings

variable "map_example" {
    description = "An example of a map in Terraform"
    type = map(string)
    default = {
        key1 = "value1"
        key2 = "value2"
        key3 = "value3"
    }
}


# a complex object

variable "object_example" {
    description = "An example of a structural type in Terraform"
    type = object({
        name = string
        age= number
        tags= list(string)
        enabled = bool
    })
    default = {
        name = "value1"
        age = 42
        tags = ["a", "b", "c"]
        enabled = true
    }
}

```


**Note**: For the EC2 instance example in `main.tf`  if the input variable `server_port`  has no default, and you run the apply command, 
Terraform will interactively prompt you to enter a value for `server_por`t and show you the description of the variable:
```bash
$ terraform apply
var.server_port
The port the server will use for HTTP requests
Enter a value:
```
If you don’t want to deal with an interactive prompt, you can provide a value for the variable via the -var command-line option:

```bash
$ terraform plan -var "server_port=8080"
```

You could also set the variable via an environment variable named `TF_VAR_<name>`, where `<name>` is the name of the variable you’re trying to set:
```bash
$ export TF_VAR_server_port=8080
$ terraform plan
```


And if you don’t want to deal with remembering extra command-line arguments every time you run `plan` or `apply`, you can specify a `default` value:

```json
    variable "server_port" {
        description = "The port the server will use for HTTP requests"
        type = number
        default = 8080
    }
```
To use the value from an input variable in your Terraform code, you can use a new type of expression called a variable reference, which has the
following syntax:

```
var.<VARIABLE_NAME>
```

In addition to input variables, Terraform also allows you to define output variables by using the following syntax:

```json
output "<NAME>" {
    value = <VALUE>
    [CONFIG ...]
}
```

The `NAME` is the name of the output variable, and `VALUE` can be any Terraform expression that you would like to output. The `CONFIG` can
contain the following optional parameters:
- **description**

    It’s always a good idea to use this parameter to document what type of data is contained in the output variable.
    
- **sensitive** 

    Set this parameter to true to instruct Terraform not to log this output at the end of `plan` or `apply`. This is useful if the output variable contains secrets such as passwords or private keys. Note that if your output variable references an input variable or resource attribute marked with sensitive = true, you are required to mark the output variable with `sensitive = true` as well _to indicate you are intentionally outputting a secret._

- **depends_on**
    
    Normally, Terraform automatically figures out your dependency graph based on the references within your code, but in rare situations, you
    have to give it extra hints. For example, perhaps you have an output variable that returns the IP address of a server, but that IP won’t be accessible until a security group (firewall) is properly configured for that server. In that case, you may explicitly tell Terraform there is a dependency between the IP address output variable and the security group resource using `depends_on`.

For example, instead of having to manually poke around the EC2 console to find the IP address of your server, you can provide the IP address as an output variable:

```json

    output "public_ip" {
    value
    = aws_instance.example.public_ip
    description = "The public IP address of the web server"
}
```


You can also use the terraform output command to list all outputs without applying any changes:

```bash
$ terraform output
public_ip = "54.174.13.5"
```
And you can run terraform output `<OUTPUT_NAME>` to see the value of a specific output called `<OUTPUT_NAME>`:
```bash
$ terraform output public_ip
"54.174.13.5"
```

This is particularly handy for scripting. For example, you could create a deployment script that runs terraform apply to deploy the web server,
uses terraform output `public_ip` to grab its public IP, and runs `curl` on the IP as a quick smoke test to validate that the deployment worked.
