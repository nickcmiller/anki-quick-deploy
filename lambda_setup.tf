#Defines a data resource of type "archive_file" named "zip_the_python_code". 
data "archive_file" "zip_the_python_code" {
  type = "zip"
  # Creates a zip archive file by combining the contents of the "python" directory and saving it to the specified output path
  source_dir = "${path.module}/python/"
  # The output path for the zip file is being set to a file 
  # Named after the value of the "lambda_name" local variable in the "python" directory
  output_path = "${path.module}/python/anki_lambda.zip"
}


resource "aws_iam_policy" "anki_lambda_policy" {
  name        = "anki_lambda_policy"
  description = "An Lambda policy for Anki"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "anki_lambda_role" {
  name               = "anki_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "anki_lambda_role_policy_attachment" {
  policy_arn = aws_iam_policy.anki_lambda_policy.arn
  role       = aws_iam_role.anki_lambda_role.name
}