data "aws_ami" "ubuntu"{
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

resource "aws_security_group" "web" {
    name = "tf-web-sg"
    description = "SSH & HTTP allow"

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "main" {
    key_name = "tf_key"
    public_key = file("~/.ssh/aws_tf.pub")
}

resource "aws_instance" "web" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    key_name = aws_key_pair.main.key_name
    vpc_security_group_ids = [aws_security_group.web.id]
    user_data_replace_on_change = true

    user_data = <<-EOF
        #!/bin/bash
        apt update -y
        apt install nginx -y
        echo "<h1>Hi! <br>This is Isti!</h1> <p>Welcome from AWS!!!" > /var/www/html/index.html
    EOF

    tags = {
        Name = "tf-web"
    }
}