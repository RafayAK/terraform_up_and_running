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