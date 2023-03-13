provider "aws" {
  region = "us-east-1"
}

#zip and policies done in lambda_setup.tf
resource "aws_lambda_function" "lambda_function" {
  #Uses the Python file that is zipped in main.tf
  filename      = "${path.module}/python/anki_lambda.zip"
  function_name = "Anki-Lambda"
  #Attach IAM role to Lambda
  role          = aws_iam_role.anki_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 60
  #Wait until IAM Policy is attached to IAM role before creating
  depends_on    = [aws_iam_role_policy_attachment.anki_lambda_role_policy_attachment]
}

# Define the API Gateway deployment
resource "aws_api_gateway_deployment" "anki_lambda_deployment" {
  rest_api_id = aws_api_gateway_rest_api.anki_lambda_rest_api.id
  stage_name  = "prod"
  
  depends_on = [
    aws_api_gateway_method_response.anki_lambda_method_response
  ]
}