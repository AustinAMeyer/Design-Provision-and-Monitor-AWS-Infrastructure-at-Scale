# TODO: Define the output variable for the lambda function.
output "lambda" {
  value = aws_lambda_function.Lambda_Func.id
  description = "This is to say hello"
}