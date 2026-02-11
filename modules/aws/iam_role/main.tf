
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

/************************************************************
cp-db-migrator
************************************************************/
resource "aws_iam_role" "cp_db_migrator" {
  name = "cp-db-migrator-${var.env}"

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

/************************************************************
cp-nat
************************************************************/
resource "aws_iam_role" "cp_nat" {
  name = "cp-nat-${var.env}"

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

resource "aws_iam_role_policy_attachment" "cp_nat" {
  for_each = {
    ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  role       = aws_iam_role.cp_nat.name
  policy_arn = each.value
}

/************************************************************
ecs-task-execution
************************************************************/
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution-${var.env}"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  for_each = {
    task_execution  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    secrets_manager = aws_iam_policy.secrets_manager_read.arn
    s3              = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    cloudwatch      = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }

  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = each.value
}

/************************************************************
cp-slack-metrics-client
************************************************************/
resource "aws_iam_role" "cp_slack_metrics_client" {
  name = "cp-slack-metrics-client-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_slack_metrics_client" {
  for_each = {
    cloudwatch = aws_iam_policy.cloud_watch_logs_write.arn
  }

  role       = aws_iam_role.cp_slack_metrics_client.name
  policy_arn = each.value
}

/************************************************************
cp-scheduler-slack-metrics
************************************************************/
resource "aws_iam_role" "cp_scheduler_slack_metrics" {
  name = "cp-scheduler-slack-metrics-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_scheduler_slack_metrics" {
  for_each = {
    ecs_run_task          = aws_iam_policy.ecs_run_task.arn
    pass_role_to_ecs_task = aws_iam_policy.pass_role_to_ecs_task.arn
  }

  role       = aws_iam_role.cp_scheduler_slack_metrics.name
  policy_arn = each.value
}

/************************************************************
cp-scheduler-cost-cutter
************************************************************/
resource "aws_iam_role" "cp_scheduler_cost_cutter" {
  name = "cp-scheduler-cost-cutter-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cp_scheduler_cost_cutter" {
  for_each = {
    ecs = aws_iam_policy.ecs_write.arn
    rds = aws_iam_policy.rds_start_stop.arn
    ec2 = aws_iam_policy.ec2_start_stop.arn
  }

  role       = aws_iam_role.cp_scheduler_cost_cutter.name
  policy_arn = each.value
}

/************************************************************
administrator
************************************************************/
resource "aws_iam_role" "administrator" {
  name = "administrator-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::043309350350:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "administrator" {
  for_each = {
    administrator = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  role       = aws_iam_role.administrator.name
  policy_arn = each.value
}
