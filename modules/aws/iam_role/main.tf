
/************************************************************
slack-metrics-backend
************************************************************/
resource "aws_iam_role" "cp_slack_metrics_backend" {
  name = "cp-slack-metrics-backend-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_slack_metrics_backend" {
  for_each = {
    cloudwatch = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ses        = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
    sqs        = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    ssm_core   = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  role       = aws_iam_role.cp_slack_metrics_backend.name
  policy_arn = each.value
}

/************************************************************
cp-bastion
************************************************************/
resource "aws_iam_role" "cp_bastion" {
  name = "cp-bastion-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_bastion" {
  for_each = {
    ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  role       = aws_iam_role.cp_bastion.name
  policy_arn = each.value
}
