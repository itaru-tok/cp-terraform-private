variable "env" {
  type = string
}

variable "ntf_alarm" {
  type = object({
    iam_role_arn     = string
    sns_topic_arn    = string
    slack_team_id    = string
    slack_channel_id = string
  })
}
