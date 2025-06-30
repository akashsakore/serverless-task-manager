resource "aws_dynamodb_table" "tasks" {
  name         = "tasks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "task_id"

  attribute {
    name = "task_id"
    type = "S"
  }
}

resource "aws_lambda_function" "task_manager" {
  function_name = "task-manager-api"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "app.handler"
  runtime       = "python3.12"
  filename      = "${path.module}/../package/app.zip"
  source_code_hash = filebase64sha256("${path.module}/../package/app.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.tasks.name
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "task-manager-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.task_manager.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.task_manager.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
