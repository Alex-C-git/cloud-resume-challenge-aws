resource "aws_iam_role" "aws_iam_lambda" {
  name = "iam_for_lambda"

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

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/packedlambda.zip"
}

resource "aws_iam_policy" "iam_policy_for_resume_project" {
  name        = "aws_iam_policy_project_terraform_lambda"
  description = "My IAM policy for the resume project"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:us-east-1:231431559866:table/cloud-resume-test",
      },
      {
        Action   = "dynamodb:GetRecords",
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:us-east-1:231431559866:table/cloud-resume-test",
      },
      {
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action   = "logs:CreateLogGroup",
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.aws_iam_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_resume_project.arn
}

resource "aws_lambda_function" "func" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_path    
  function_name    = "func"
  role             = aws_iam_role.aws_iam_lambda.arn
  handler          = "func.lambda_handler"
  runtime          = "python3.8"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_lambda_function_url" "url1" {
  function_name      = aws_lambda_function.func.function_name
  authorization_type = "NONE" 

  cors {
    allow_credentials = true
    allow_origins     = ["https://alexandercloudresume.com"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
