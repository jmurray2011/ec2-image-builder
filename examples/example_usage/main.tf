module "ami_builder" {
  source = "../../modules/ami_builder"

  region = var.region
  component_data = file("${path.module}/component_data.yaml")
  # Additional variables...
}