data "archive_file" "ondemand_minecraft_task_starter_lambda_zip" {
  type = "zip"
  source_content = templatefile("../lambda/lambda_function.py", {
    aws_region = var.aws_region
  })
  source_content_filename = "lambda_function.py"
  output_path             = "lambda_function.zip"
}

resource "aws_lambda_function" "ondemand_minecraft_task_starter_lambda" {
  provider = aws.us-east-1
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
  provider      = aws.us-east-1
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ondemand_minecraft_task_starter_lambda.function_name
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = format("%s:*", aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.arn)
}