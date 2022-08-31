

data "local_file" "index" {
  filename = "${path.module}/lambda/index.js"
}

data "archive_file" "lambdazip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = data.local_file.index.content
    filename = "index.js"
  }

  source {
    content  = local.config_json
    filename = "config.json"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda.arn
  publish       = true
  runtime       = "nodejs12.x"
  handler       = "index.handler"
  tags          = local.tags
  memory_size   = 128
  timeout       = 5

  filename         = data.archive_file.lambdazip.output_path
  source_code_hash = data.archive_file.lambdazip.output_base64sha256
}
