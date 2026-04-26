/************************************************************
ntf-alarm
CloudWatch Alarm からの通知を集約し、Amazon Q Developer
(Chatbot) 経由で Slack へ配信するための SNS トピック。
************************************************************/
resource "aws_sns_topic" "ntf_alarm" {
  name = "ntf-alarm-${var.env}"
}
