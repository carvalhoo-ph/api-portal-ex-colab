# GitHub Actions IAM Role and Policy
resource "aws_iam_role" "github_actions" {
  name = "github_actions_role_${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
          // Adicione o principal do GitHub Actions
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:<your-repo>:ref:refs/heads/<your-branch>"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "github_actions_policy" {
  name = "github_actions_policy_${random_string.suffix.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "apigateway:POST",
          "apigateway:GET",
          "apigateway:PUT",
          "apigateway:DELETE",
          "apigateway:PATCH",
          "apigateway:HEAD",
          "apigateway:OPTIONS"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:CreateRole",
          "iam:CreatePolicy",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# Lambda Execution IAM Role and Policy
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role_${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy_${random_string.suffix.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw_periodo_demonstrativo_get" {
  statement_id  = "AllowAPIGatewayInvokePeriodoDemonstrativoGET"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.periodo_demonstrativo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/*/GET/periodo-demonstrativo"
}

resource "aws_lambda_permission" "apigw_periodo_demonstrativo_options" {
  statement_id  = "AllowAPIGatewayInvokePeriodoDemonstrativoOPTIONS"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.periodo_demonstrativo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/*/OPTIONS/periodo-demonstrativo"
}

resource "aws_lambda_permission" "apigw_login_post" {
  statement_id  = "AllowAPIGatewayInvokeLoginPOST"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/*/POST/login"
}

resource "aws_lambda_permission" "apigw_login_options" {
  statement_id  = "AllowAPIGatewayInvokeLoginOPTIONS"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/*/OPTIONS/login"
}

resource "aws_lambda_permission" "apigw_demonstrativo_pgto_get" {
  statement_id  = "AllowAPIGatewayInvokeDemonstrativoPgtoGET"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.demonstrativo_pgto.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/*/GET/demonstrativo-pgto"
}

resource "aws_lambda_permission" "apigw_demonstrativo_pgto_options" {
  statement_id  = "AllowAPIGatewayInvokeDemonstrativoPgtoOPTIONS"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.demonstrativo_pgto.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/*/OPTIONS/demonstrativo-pgto"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
