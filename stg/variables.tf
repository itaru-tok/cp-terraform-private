locals {
  env                               = "stg"
  account_id                        = "424848769759"
  region                            = "ap-northeast-1"
  base_host                         = "stg.itaru.uk"
  ses_mail_from_domain              = "mail.stg.itaru.uk"
  amplify_domain_name_slack_metrics = "develop.d15icriq5um5ws.amplifyapp.com"

  # EKS Pod Identity 用（コンソールのクラスター名と一致）
  eks_cluster_name = "cloud-pratica-stg"

  # 既存クラスタを import する場合はコンソールのバージョンと一致させる（ずれると plan で差分や置換が出る）
  eks_kubernetes_version = "1.35"

  # slack-metrics-api Lambda（コンテナ）のイメージタグ。import 前にコンソールまたは ECR の実タグに合わせる
  slack_metrics_lambda_image_tag = "c5029c5"

  # Step Functions 学習用 practice-lambda-calculate。`make release-image` の GIT_COMMIT_HASH（短縮）に合わせて更新する
  practice_lambda_calculate_image_tag = "f020be2"

  # media-compressor-compress-image。`make release-image` の GIT_COMMIT_HASH（短縮）に合わせて更新する
  media_compressor_compress_image_image_tag = "f020be2"

  # media-compressor-compress-video。`make release-image` の GIT_COMMIT_HASH（短縮）に合わせて更新する
  media_compressor_compress_video_image_tag = "f020be2"

  # media-compressor-notify-result。`make release-image` の GIT_COMMIT_HASH（短縮）に合わせて更新する
  media_compressor_notify_result_image_tag = "f020be2"

  # media-compressor-invoker。初回は ECR に push したイメージタグに合わせて更新する
  media_compressor_invoker_image_tag = "f020be2"

  # firehose-cwlogs-transformer。`make release-image` 後に push したイメージタグへ更新する
  firehose_cwlogs_transformer_image_tag = "f020be2"

  # cost-api タスク定義に同居するコンテナのイメージタグ。CI/CD で更新される。
  cost_aggregator_image_tag = "40947a0"
  cost_provider_image_tag   = "40947a0"

  # Step Functions コンソールのステートマシン名と一致させる（例: media-compressor-stg）
  media_compressor_state_machine_arn = "arn:aws:states:${local.region}:${local.account_id}:stateMachine:media-compressor-${local.env}"

  datadog_keys = jsondecode(
    data.aws_secretsmanager_secret_version.datadog_keys.secret_string
  )
  datadog_apm_view_url_cost_provider = "https://ap1.datadoghq.com/apm/entity/service%3Acost-provider?env=${local.env}"
}

data "aws_secretsmanager_secret_version" "datadog_keys" {
  secret_id = "datadog-keys-${local.env}"
}
