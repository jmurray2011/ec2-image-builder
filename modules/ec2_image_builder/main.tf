resource "random_id" "server" {
  byte_length = 12
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-key}"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key_output" {
  content  = tls_private_key.this.private_key_pem
  filename = "${path.module}/test_key.pem"
}

output "private_key_path" {
  value     = local_file.private_key_output.filename
  sensitive = true
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}_ImageBuilderInstanceProfile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = "${var.name_prefix}_ImageBuilderInstanceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder",
  "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"]
}


resource "aws_imagebuilder_component" "dynamic_component" {
  name        = "${var.name_prefix}_component"
  description = "Dynamic component that installs user-defined software and configurations"
  version     = "1.0.0"
  platform    = "Linux"

  data = var.component_data
}

resource "aws_imagebuilder_image_recipe" "this" {
  name         = "${var.name_prefix}-recipe"
  description  = var.recipe_description
  version      = "1.0.0"
  parent_image = var.parent_image

  block_device_mapping {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp2"
    }
  }

  component {
    component_arn = aws_imagebuilder_component.dynamic_component.arn
  }

  dynamic "component" {
    for_each = var.additional_components

    content {
      component_arn = component.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name = "${var.name_prefix}_InfrastructureConfiguration"

  instance_profile_name = aws_iam_instance_profile.this.name
  instance_types        = ["t3.medium"]
  key_pair              = aws_key_pair.this.key_name
}

resource "aws_imagebuilder_distribution_configuration" "this" {
  name = "${var.name_prefix}_DistributionConfiguration"

  distribution {
    region = var.region
    ami_distribution_configuration {
      name = "${var.name_prefix}-{{ imagebuilder:buildDate }}"
      ami_tags = {
        Name = "${var.name_prefix}-{{ imagebuilder:buildDate }}"
      }
    }
  }

  tags = {
    Name = "${var.name_prefix}-AMI"
  }
}

resource "aws_imagebuilder_image_pipeline" "this" {
  name = "${var.name_prefix}_ImagePipeline"

  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.this.arn

  enhanced_image_metadata_enabled = true
}
