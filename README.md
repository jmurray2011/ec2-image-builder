# AWS Test Webserver Image Builder using Terraform

This Terraform module provides a structured way to create an AWS EC2 image (AMI) using AWS Image Builder. The generated image is based on Ubuntu 20.04 and is configured with a basic web server setup, serving a static "Hello World!" page. The module ensures that the necessary AWS resources, such as IAM roles and policies, are created and configured correctly to facilitate the image building process.

## Prerequisites

- Terraform v1.0+
- AWS CLI configured with appropriate AWS credentials
- An AWS account

## Quick Start

1. **Clone the Repository:**
   ```shell
   git clone [repository_url]
   ```
   
2. **Navigate to the Project Directory:**
   ```shell
   cd [project_directory]
   ```
   
3. **Initialize Terraform:**
   ```shell
   terraform init
   ```
   
4. **Apply the Terraform Configuration:**
   ```shell
   terraform apply
   ```
   
## Module Components

### AWS Provider and Required Providers

The module is configured to use the AWS provider and has been tested with version `5.18.1` of the AWS provider plugin.

### IAM Role and Policies

An IAM role `ImageBuilderInstanceRole` and an instance profile `ImageBuilderInstanceProfile` are created to allow EC2 instances to perform the necessary actions during the image-building process. The role is attached with AWS managed policies that grant permissions for EC2 Image Builder and Amazon SSM.

### AWS Key Pair

A new RSA key pair `test_webserver_key` is generated and stored both in AWS and locally as `test_key.pem`. This key pair is used to launch the EC2 instance during the image-building process.

### AWS Image Builder Components

- **Component:** A custom component `test_webserver_imagebuilder_component` is defined to perform the following during the build phase:
  - Update and upgrade the system packages.
  - Install necessary software (git, unzip, jq, net-tools, python3-pip, python-is-python3, apache2).
  - Configure Apache to serve a static "Hello World!" page.
  
- **Image Recipe:** An image recipe `test_webserver_imagebuilder_image_recipe` is defined using the custom component and two AWS provided components for Amazon CloudWatch Agent and AWS CLI version 2.

- **Infrastructure Configuration:** An infrastructure configuration `test_webserver_imagebuilder_infra_config` is defined to specify the instance type and key pair used during the build.

- **Distribution Configuration:** A distribution configuration `test_webserver_imagebuilder_dist_config` is defined to specify the region where the AMI will be available and the naming convention for the AMI.

- **Image Pipeline:** An image pipeline `test_webserver_imagebuilder_pipeline` is defined to tie together the recipe, infrastructure configuration, and distribution configuration, enabling the automated building and testing of the image.

## Outputs

- **Account ID:** The AWS account ID is output to the console.
- **Private Key Path:** The path to the locally stored private key is output to the console. Note that this output is marked as sensitive.

## Variables

- **region:** AWS region where resources will be created. Default is `us-east-2`.

## Usage Notes

- Ensure that your AWS credentials are configured correctly to allow the creation of the specified resources.
- The private key is stored locally and should be secured appropriately.
- The generated AMI will be named in the format `test_webserver-worker-[buildDate]` and tagged with `Name: test_webserver-worker-AMI`.
- Ensure to destroy the resources after testing to avoid incurring unnecessary AWS costs.

## Cleanup

To destroy the created resources, use the following Terraform command:

```shell
terraform destroy
```

Ensure to verify in the AWS Management Console that all resources created during the apply phase are destroyed.