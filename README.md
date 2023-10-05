# EC2 Image Builder Terraform Module

## Introduction

This Terraform module automates the creation of Amazon Machine Images (AMIs) using the AWS EC2 Image Builder service. It's designed to be flexible and reusable across various AWS environments.

## Key Components

- **Dynamic Component:** Enables custom software and configuration installations during the AMI build process.
- **Key Pair Management:** Generates and manages an AWS Key Pair for EC2 instance access.
- **IAM Role & Instance Profile:** Establishes necessary IAM roles and instance profiles for EC2 Image Builder.
- **Image Recipe Management:** Manages the creation and configuration of Image Builder recipes.
- **Infrastructure Configuration:** Manages configurations related to the image build process.
- **Distribution Configuration:** Handles the distribution settings of the AMI.
- **Image Pipeline:** Automates the AMI build process using the defined recipe and configurations.

## Usage

### Module Usage Example

```hcl
module "ami_builder" {
  source              = "../../modules/ec2_image_builder"
  region              = var.region
  name_prefix         = "example"
  component_data      = file("${path.module}/component_data.yaml")
  recipe_description  = "Example AMI build recipe"
  additional_components = [
    "arn:aws:imagebuilder:${var.region}:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1",
    "arn:aws:imagebuilder:${var.region}:aws:component/aws-cli-version-2-linux/1.0.4/1"
  ]
}
```

### Variables

- `region`: AWS region for resource creation.
- `name_prefix`: Prefix for naming AWS resources.
- `component_data`: YAML string defining software and configurations for the AMI.
- `recipe_description`: Description of the image recipe.
- `additional_components`: Additional component ARNs for the image recipe.

### Outputs

- `account_id`: AWS account ID.
- `region`: AWS region.

## Prerequisites

- Configured AWS CLI with necessary credentials.
- Terraform v1.x.x+.

## Notes

- Validate the `component_data` YAML for syntax and logical errors.
- Ensure the executing AWS profile has the necessary IAM permissions.
- Secure and manage the private key file according to security best practices.

## License

MIT License.
