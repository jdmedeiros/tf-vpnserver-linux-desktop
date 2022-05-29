output "solr_public_ip" {
  description = "Solr public IP "
  value = aws_eip.vpn_eip.public_ip
}

output "solr_public_dns" {
  description = "Solr public DNS "
  value = aws_instance.vpn.public_dns
}

output "solr_private_ip" {
  description = "Solr private IPs "
  value = aws_instance.vpn.private_ip
}

# Some sanity checking to make sure we are in the right account - very important if you use multiple accounts
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}