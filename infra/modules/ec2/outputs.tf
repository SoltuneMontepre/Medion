output "ec2_instance_id" {
  value = aws_instance.this.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.this.public_ip
}

output "ec2_instance_public_dns" {
  value = aws_instance.this.public_dns
}

output "ec2_ssh_security_group_id" {
  value = aws_security_group.ssh.id
}
