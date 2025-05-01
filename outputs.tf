output "iam_data_without_decoding" {
  value = local.iam_data
}

output "iam_data_with_decoding" {
  value = local.iam_data_decode
}

output "user_names" {
  value = local.all_usernames
}

output "group_names" {
  value = local.all_groups
}

output "policy_names" {
  value = toset(flatten([
    local.iam_data_decode.developers[*].permissions,
    local.iam_data_decode.operations[*].permissions
  ]))
}

output "user_access_keys" {
  value     = values(aws_iam_access_key.user_keys)[*].id
  sensitive = true
}

output "user_secret_keys" {
  value     = values(aws_iam_access_key.user_keys)[*].secret
  sensitive = true
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "user_passwords" {
  value     = values(aws_iam_user_login_profile.user_login_profile)[*].password
  sensitive = true
}