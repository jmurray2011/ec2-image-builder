resource "tls_private_key" "test_webserver_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "test_webserver_key" {
  key_name   = "test_webserver_key"
  public_key = tls_private_key.test_webserver_key.public_key_openssh
}

resource "local_file" "private_key_output" {
  content  = tls_private_key.test_webserver_key.private_key_pem
  filename = "${path.module}/test_key.pem"
}

output "private_key_path" {
  value     = local_file.private_key_output.filename
  sensitive = true
}

resource "aws_iam_instance_profile" "imagebuilder_instance_profile" {
  name = "ImageBuilderInstanceProfile"
  role = aws_iam_role.imagebuilder_instance_role.name
}

resource "aws_iam_role" "imagebuilder_instance_role" {
  name = "ImageBuilderInstanceRole"
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


resource "aws_imagebuilder_component" "test_webserver_imagebuilder_component" {
  name        = "test_webserver_imagebuilder_component"
  description = "Install Pre-requisites, configure SSM"
  version     = "1.0.0"
  platform    = "Linux"

  data = <<-EOD
name: InstallSoftware
description: Install Pre-requisites, configure SSM
schemaVersion: 1.0

phases:
  - name: build
    steps:
      - name: InstallPrerequisites
        action: ExecuteBash
        inputs:
          commands:
            - apt-get update -y
            - apt-get upgrade -y
            - apt-get install -y git unzip jq net-tools python3-pip python-is-python3 apache2
      - name: ConfigureDefaultApachePage
        action: ExecuteBash
        inputs:
          commands:
            - echo "Hello World!" > /var/www/html/index.html
            - systemctl enable apache2
            - systemctl start apache2
EOD

}

data "aws_ami" "ubuntu_20_04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_imagebuilder_image_recipe" "test_webserver_imagebuilder_image_recipe" {
  name         = "test_webserver_imagebuilder_image_recipe"
  description  = "Recipe to build a Test Webserver AMI"
  version      = "1.0.0"
  parent_image = data.aws_ami.ubuntu_20_04.image_id

  block_device_mapping {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp2"
    }
  }
  component {
    component_arn = "arn:aws:imagebuilder:us-east-2:aws:component/amazon-cloudwatch-agent-linux/1.0.1/1"
  }
  component {
    component_arn = "arn:aws:imagebuilder:us-east-2:aws:component/aws-cli-version-2-linux/1.0.4/1"
  }
  component {
    component_arn = aws_imagebuilder_component.test_webserver_imagebuilder_component.arn
  }
}

resource "aws_imagebuilder_infrastructure_configuration" "test_webserver_imagebuilder_infra_config" {
  name = "test_webserver_imagebuilder_infra_config"

  instance_profile_name = aws_iam_instance_profile.imagebuilder_instance_profile.name
  instance_types        = ["t3.medium"]
  key_pair              = aws_key_pair.test_webserver_key.key_name
}

resource "aws_imagebuilder_distribution_configuration" "test_webserver_imagebuilder_dist_config" {
  name = "test_webserver_imagebuilder_dist_config"

  distribution {
    region = var.region
    ami_distribution_configuration {
      name = "test_webserver-worker-{{ imagebuilder:buildDate }}"
    }
  }

  tags = {
    Name = "test_webserver-worker-AMI"
  }
}

resource "aws_imagebuilder_image_pipeline" "test_webserver_imagebuilder_pipeline" {
  name = "test_webserver_imagebuilder_pipeline"

  image_recipe_arn                 = aws_imagebuilder_image_recipe.test_webserver_imagebuilder_image_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.test_webserver_imagebuilder_infra_config.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.test_webserver_imagebuilder_dist_config.arn

  enhanced_image_metadata_enabled = true
}
