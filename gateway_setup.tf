# Create an IAM role for API Gateway to assume
resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Define a custom IAM policy that allows API Gateway to invoke the Lambda function
resource "aws_iam_policy" "api_gateway_lambda_policy" {
  name = "api_gateway_lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "lambda:InvokeFunction"
        Resource  = aws_lambda_function.lambda_function.arn
      }
    ]
  })
}

# Attach the custom IAM policy to the IAM role for API Gateway to assume
resource "aws_iam_role_policy_attachment" "api_gateway_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.api_gateway_lambda_policy.arn
  role       = aws_iam_role.api_gateway_role.name
}

# Define the API Gateway REST API
resource "aws_api_gateway_rest_api" "anki_lambda_rest_api" {
  name        = "anki_lambda_rest_api"
  description = "API Gateway for the Anki Lambda function"
}

# Define the API Gateway resource
resource "aws_api_gateway_resource" "anki_lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.anki_lambda_rest_api.id
  parent_id   = aws_api_gateway_rest_api.anki_lambda_rest_api.root_resource_id
  path_part   = "anki"
}

# Define the API Gateway method
resource "aws_api_gateway_method" "anki_lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.anki_lambda_rest_api.id
  resource_id   = aws_api_gateway_resource.anki_lambda_resource.id
  request_models = {
      "application/json" = "Empty"
  }
  http_method   = "POST"
  authorization = "NONE"
}

# Define the API Gateway integration
resource "aws_api_gateway_integration" "anki_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.anki_lambda_rest_api.id
  resource_id             = aws_api_gateway_resource.anki_lambda_resource.id
  http_method             = aws_api_gateway_method.anki_lambda_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
  credentials = aws_iam_role.api_gateway_role.arn
}

# # Define the API Gateway integration response
# resource "aws_api_gateway_integration_response" "anki_lambda_integration_response" {
#   rest_api_id          = aws_api_gateway_rest_api.anki_lambda_rest_api.id
#   resource_id          = aws_api_gateway_resource.anki_lambda_resource.id
#   http_method          = aws_api_gateway_method.anki_lambda_method.http_method
#   status_code          = aws_api_gateway_method_response.anki_lambda_method_response.status_code
#   response_templates   = {
#     "application/json" = "$input.json('$')"
#   }
# }

resource "aws_api_gateway_method_response" "anki_lambda_method_response" {
  rest_api_id = aws_api_gateway_rest_api.anki_lambda_rest_api.id
  resource_id = aws_api_gateway_resource.anki_lambda_resource.id
  http_method = aws_api_gateway_method.anki_lambda_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  
}