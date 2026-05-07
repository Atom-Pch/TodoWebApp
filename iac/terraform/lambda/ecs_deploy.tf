# 1. Package the Python script into a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/ecs_deploy.py"
  output_path = "${path.module}/ecs_deploy.zip"
}

# 2. IAM Role & Policy for the Lambda Function
resource "aws_iam_role" "lambda_ecs_deploy_role" {
  name = "ecs-deploy-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# DevOps Best Practice: Explicit least-privilege permissions
resource "aws_iam_role_policy" "lambda_ecs_deploy_policy" {
  name = "ecs-deploy-lambda-policy"
  role = aws_iam_role.lambda_ecs_deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow Lambda to write logs to CloudWatch
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        # Allow Lambda to force-update ECS services
        Effect = "Allow"
        Action = [
          "ecs:UpdateService"
        ]
        Resource = [
          var.todo_cluster_arn,
          var.frontend_service_arn,
          var.backend_service_arn
        ]
      }
    ]
  })
}

# 3. The Lambda Function
resource "aws_lambda_function" "ecs_deploy_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "trigger-ecs-deploy"
  role             = aws_iam_role.lambda_ecs_deploy_role.arn
  handler          = "ecs_deploy.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      # Make sure these match the exact names of your resources!
      ECS_CLUSTER_NAME      = var.todo_cluster_name
      FRONTEND_REPO_NAME    = var.frontend_repo_name
      FRONTEND_SERVICE_NAME = var.frontend_service_name
      BACKEND_REPO_NAME     = var.backend_repo_name
      BACKEND_SERVICE_NAME  = var.backend_service_name
    }
  }
}

# 4. EventBridge Rule to detect ECR pushes
resource "aws_cloudwatch_event_rule" "ecr_push_latest" {
  name        = "ecr-push-latest-trigger"
  description = "Triggers when 'latest' tag is pushed to frontend or backend ECR"

  # This JSON explicitly filters for the exact events we care about
  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      "action-type"     = ["PUSH"]
      "result"          = ["SUCCESS"]
      "image-tag"       = ["latest"]
      "repository-name" = [var.frontend_repo_name, var.backend_repo_name]
    }
  })
}

# 5. Connect EventBridge to Lambda
resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.ecr_push_latest.name
  target_id = "TriggerECSDeployLambda"
  arn       = aws_lambda_function.ecs_deploy_lambda.arn
}

# 6. Allow EventBridge to invoke the Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_deploy_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_push_latest.arn
}
