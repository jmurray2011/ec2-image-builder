data "aws_caller_identity" "current" {}

module "ami_builder" {
  source = "../../modules/ec2_image_builder"

  region             = var.region
  name_prefix        = "test_example"
  component_data     = file("${path.module}/component_data.yaml")
  recipe_description = "Recipe to build a Test Webserver AMI"
  additional_components = [
    "arn:aws:imagebuilder:${var.region}:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1",
    "arn:aws:imagebuilder:${var.region}:aws:component/aws-cli-version-2-linux/1.0.4/1"
  ]

  default_tags = {
    Environment   = "default"
    ManagedBy     = "Terraform"
    ManagedByTeam = "DevOps"
    Project       = "Image Builder"
  }
}
