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

resource "aws_iam_policy" "lambda_permission_policy_periodo_demonstrativo" {
  name = "lambda_permission_policy_periodo_demonstrativo_${random_string.suffix.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect = "Allow"
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${data.aws_lambda_function.periodo_demonstrativo.function_name}"
        ],
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Condition = {
          ArnLike = {
            "AWS:SourceArn": [
              "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/GET/periodo-demonstrativo",
              "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/OPTIONS/periodo-demonstrativo"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_permission_policy_login" {
  name = "lambda_permission_policy_login_${random_string.suffix.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect = "Allow"
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${data.aws_lambda_function.login.function_name}"
        ],
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Condition = {
          ArnLike = {
            "AWS:SourceArn": [
              "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/POST/login",
              "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/OPTIONS/login"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_permission_policy_demonstrativo_pgto" {
  name = "lambda_permission_policy_demonstrativo_pgto_${random_string.suffix.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect = "Allow"
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${data.aws_lambda_function.demonstrativo_pgto.function_name}"
        ],
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Condition = {
          ArnLike = {
            "AWS:SourceArn": [
              "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/GET/demonstrativo-pgto",
              "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/OPTIONS/demonstrativo-pgto"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_permission_attach_periodo_demonstrativo" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_permission_policy_periodo_demonstrativo.arn
}

resource "aws_iam_role_policy_attachment" "lambda_permission_attach_login" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_permission_policy_login.arn
}

resource "aws_iam_role_policy_attachment" "lambda_permission_attach_demonstrativo_pgto" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_permission_policy_demonstrativo_pgto.arn
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw_login_part1" {
  statement_id  = "AllowAPIGatewayInvokeLoginPart1"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/POST/login"
}

resource "aws_lambda_permission" "apigw_login_part2" {
  statement_id  = "AllowAPIGatewayInvokeLoginPart2"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/OPTIONS/login"
}

resource "aws_lambda_permission" "apigw_periodo_demonstrativo_part1" {
  statement_id  = "AllowAPIGatewayInvokePeriodoDemonstrativoPart1"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.periodo_demonstrativo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/GET/periodo-demonstrativo"
}

resource "aws_lambda_permission" "apigw_periodo_demonstrativo_part2" {
  statement_id  = "AllowAPIGatewayInvokePeriodoDemonstrativoPart2"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.periodo_demonstrativo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/OPTIONS/periodo-demonstrativo"
}

resource "aws_lambda_permission" "apigw_demonstrativo_pgto_part1" {
  statement_id  = "AllowAPIGatewayInvokeDemonstrativoPgtoPart1"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.demonstrativo_pgto.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/GET/demonstrativo-pgto"
}

resource "aws_lambda_permission" "apigw_demonstrativo_pgto_part2" {
  statement_id  = "AllowAPIGatewayInvokeDemonstrativoPgtoPart2"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.demonstrativo_pgto.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.new_api.id}/OPTIONS/demonstrativo-pgto"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
