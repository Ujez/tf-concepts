data "aws_availability_zones" "avilable" {}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "levelup_key2" {
  key_name   = "levelup_key2"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "DockerInstance" {
  ami           = lookup(var.AMIS, var.AWS_REGION)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.levelup_key2.key_name

  tags = {
    Name = "custom_instance2"
  }

  provisioner "file" {
    source      = "installdocker_tf.sh"
    destination = "/tmp/installdocker_tf.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installdocker_tf.sh",
      "sudo sed -i -e 's/\r$//' /tmp/installdocker_tf.sh", # Remove the spurious CR characters.
      "sudo /tmp/installdocker_tf.sh",
    ]
  }

  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
}
output "public_ip" {
  value = aws_instance.DockerInstance.public_ip
}
