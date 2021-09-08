data "archive_file" "ondemand_minecraft_task_starter_lambda_zip" {
    type          = "zip"
    source_file   = "lambda_src/task_starter.py"
    output_path   = "task_starter.zip"
}

resource "aws_lambda_function" "ondemand_minecraft_task_starter_lambda" {
  filename         = "task_starter.zip"
  function_name    = "ondemand_minecraft_task_starter"
  role             = "${aws_iam_role.ondemand_minecraft_task_starter_lambda_role.arn}"
  handler          = "task_starter.lambda_handler"
  source_code_hash = "${data.archive_file.ondemand_minecraft_task_starter_lambda_zip.output_base64sha256}"
  runtime          = "python3.9"
}