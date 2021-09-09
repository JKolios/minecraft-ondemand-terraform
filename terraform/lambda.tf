data "archive_file" "ondemand_minecraft_task_starter_lambda_zip" {
  type        = "zip"
  source_file = "../lambda/lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "ondemand_minecraft_task_starter_lambda" {
  depends_on = [
    aws_cloudwatch_log_group.lambda_function_log_group
  ]
  filename         = "lambda_function.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.ondemand_minecraft_task_starter_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.ondemand_minecraft_task_starter_lambda_zip.output_base64sha256
  runtime          = "python3.9"
  tags             = var.common_tags
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ondemand_minecraft_task_starter_lambda.function_name
  principal     = format("logs.%s.amazonaws.com", var.aws_region)
  source_arn    = format("%s:*", aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.arn)
}