resource "aws_cloudwatch_log_group" "prefect_server_log_group" {
  name              = "prefect-play-server-log-group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "prefect_worker_log_group" {
  name              = "prefect-play-worker-log-group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "prefect_flow_log_group" {
  name              = "prefect-play-flow-log-group"
  retention_in_days = 30
}
