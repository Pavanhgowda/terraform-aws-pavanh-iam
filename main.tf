provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  iam_data      = file(var.iam_data_file)
  iam_data_decode = yamldecode(local.iam_data)

  all_usernames = toset(concat(
    local.iam_data_decode.developers[*].username,
    local.iam_data_decode.operations[*].username,
  ))

  all_groups = toset(flatten([
    local.iam_data_decode.developers[*].groups,
    local.iam_data_decode.operations[*].groups
  ]))

  teams = [
    local.iam_data_decode.developers,
    local.iam_data_decode.operations
  ]

  pair_users_groups = {
    for pair in flatten([
      for team in local.teams : [
        for user in team : [
          for group in user.groups : {
            username = user.username
            group    = group
          }
        ]
      ]
    ]) : "${pair.username}-${pair.group}" => pair
  }

  pair_user_permission = {
    for pair in flatten([
      for team in local.teams : [
        for user in team : [
          for permission in user.permissions : {
            username    = user.username
            permission  = permission
          }
        ]
      ]
    ]) : "${pair.username}-${pair.permission}" => pair
  }

  group_policies = local.iam_data_decode.groups

  pair_group_policy = {
    for pair in flatten([
      for group_name, group_obj in local.group_policies : [
        for policy in lookup(group_obj, "policies", []) : {
          group_name = group_name
          policy     = policy
        }
      ]
    ]) : "${pair.group_name}-${pair.policy}" => pair
  }

  password_policy = local.iam_data_decode.password_policy
}

resource "aws_iam_user" "users" {
  for_each = local.all_usernames
  name     = each.value
}

resource "aws_iam_access_key" "user_keys" {
  for_each = local.all_usernames
  user     = each.key
}

resource "aws_iam_user_login_profile" "user_login_profile" {
  for_each = local.all_usernames
  user     = each.key
  password_length         = 20
  password_reset_required = false
}

resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length       = local.password_policy.minimum-length
  require_uppercase_characters  = local.password_policy.require-uppercase
  require_lowercase_characters  = local.password_policy.require-lowercase
  require_numbers               = local.password_policy.require-numbers
  require_symbols               = local.password_policy.require-symbols
  max_password_age              = local.password_policy.max-age-days
  password_reuse_prevention     = local.password_policy.prevent-reuse
  allow_users_to_change_password = true
}

resource "aws_iam_group" "groups" {
  for_each = local.all_groups
  name     = each.value
}

resource "aws_iam_user_group_membership" "pairing_users_groups" {
  for_each = local.pair_users_groups
  user     = each.value.username
  groups   = [each.value.group]
}

resource "aws_iam_group_policy_attachment" "group_policy_attachment" {
  for_each = local.pair_group_policy
  group    = each.value.group_name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.policy}"
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  for_each = local.pair_user_permission
  user     = each.value.username
  policy_arn = "arn:aws:iam::aws:policy/${each.value.permission}"
}