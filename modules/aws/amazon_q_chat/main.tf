/************************************************************
ntf-alarm Slack チャンネル設定
SNS トピック ntf-alarm の通知を Amazon Q Developer (Chatbot)
経由で Slack チャンネル #ntf-alarm に配信する。
************************************************************/
resource "aws_chatbot_slack_channel_configuration" "ntf_alarm" {
  configuration_name = "ntf-alarm-${var.env}"

  iam_role_arn = var.ntf_alarm.iam_role_arn

  slack_team_id    = var.ntf_alarm.slack_team_id
  slack_channel_id = var.ntf_alarm.slack_channel_id

  sns_topic_arns = [var.ntf_alarm.sns_topic_arn]

  guardrail_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]

  logging_level                = "NONE"
  user_authorization_required  = false
}
