data "aws_vpc" "myalreadyvpc" {
    default = true
    }

data "aws_security_group" "myalreadysg" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
}
data "aws_ami" "myalreadyami" {
  most_recent = true
  owners = ["099720109477"]
    filter {
      name = "name"
      values = ["ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-20250919"]
    }
}
resource "aws_key_pair" "myownkey" {
  public_key = file("~/.ssh/id_ed25519.pub")
  key_name = "novkey"
}
resource "aws_instance" "myec2" {
  ami = data.aws_ami.myalreadyami.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.myownkey.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [data.aws_security_group.myalreadysg.id]
  tags = {
    Name = "myec2"
  } 
}
 
resource "null_resource" "mychanges" {
  triggers = {
    build_id = "1.6"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
    host = aws_instance.myec2.public_ip
}


provisioner "file" {
  source = "./webapplication.sh"
  destination = "/home/ubuntu/webapplication.sh"
}

provisioner "remote-exec" {
  inline = [ "sudo chmod +x /home/ubuntu/webapplication.sh", "./webapplication.sh" ]
}

}
