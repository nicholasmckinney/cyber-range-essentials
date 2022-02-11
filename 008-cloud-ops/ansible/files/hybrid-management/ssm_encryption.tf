resource "aws_kms_key" "ssm_key" {
  provider = aws.systems
  description = "Systems Management Communication Key"
  enable_key_rotation = true
}

resource "aws_kms_alias" "ssm_key_alias" {
  provider = aws.systems
  name = "alias/ssm_communications"
  target_key_id = aws_kms_key.ssm_key.key_id
}

output "ssm_key_id" {
  value = aws_kms_key.ssm_key.key_id
}
