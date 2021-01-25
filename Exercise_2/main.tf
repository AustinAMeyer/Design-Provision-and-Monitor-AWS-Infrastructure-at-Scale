provider "aws" {
  profile = "default"
  region = var.region
}

resource "aws_iam_role" "aws_iam_for_lambda" {
  name = "aws_iam_for_lambda"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
        "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
]
}
EOF
}

data "archive_file" "init" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "Lambda_Func" {
  function_name = var.Lambda_Func
  filename      = "lambda.zip"
  role          = aws_iam_role.aws_iam_for_lambda.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.8"
  # ... other configuration ...
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]
  provisioner "local-exec" {
    # wait for lambda permissions to complete
    command = "sleep 30"
  }
  environment {
    variables = {
      greeting = "Hello!!!"
    }
  }
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "Hello_Lambda_Func" {
  name              = "/aws/lambda/${var.Lambda_Func}"
  retention_in_days = 7
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.aws_iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_sqs_queue" "aws_sqs_queue" {
  name                      = "aws_sqs_queue"
  max_message_size          = 4096
  message_retention_seconds = 60
  depends_on = [
    aws_lambda_function.Lambda_Func
  ]
}

resource "aws_lambda_event_source_mapping" "aws_sqs_queue" {
  event_source_arn = aws_sqs_queue.aws_sqs_queue.arn
  function_name    = aws_lambda_function.Lambda_Func.arn
  depends_on = [
    aws_lambda_function.Lambda_Func
  ]
}