# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

provider "random" {
  # Configuração do provedor random
}

# API Gateway Configuration
resource "aws_api_gateway_rest_api" "api" {
  name        = "API_postar_ex-colab"
  description = "API Gateway for my application"

  lifecycle {
    prevent_destroy = true
  }
}

# Periodo Demonstrativo Lambda Integration
resource "aws_api_gateway_resource" "resource_periodo_demonstrativo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "periodo-demonstrativo"
}

resource "aws_api_gateway_method" "method_periodo_demonstrativo" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method   = "GET"
  authorization = "NONE"

  response_models = {
    "application/json" = "Empty"
  }

  method_response {
    status_code = "200"

    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = true
      "method.response.header.Access-Control-Allow-Headers" = true
      "method.response.header.Access-Control-Allow-Methods" = true
    }
  }
}

data "aws_lambda_function" "periodo_demonstrativo" {
  function_name = "periodo-demonstrativo"
}

resource "aws_lambda_permission" "apigw_periodo_demonstrativo" {
  statement_id  = "AllowAPIGatewayInvokePeriodoDemonstrativo-${random_string.suffix.result}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.periodo_demonstrativo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "integration_periodo_demonstrativo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = data.aws_lambda_function.periodo_demonstrativo.invoke_arn

  integration_response {
    status_code = "200"

    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    }
  }
}

# Login Lambda Integration
resource "aws_api_gateway_resource" "resource_login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "login"
}

resource "aws_api_gateway_method" "method_login" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource_login.id
  http_method   = "POST"
  authorization = "NONE"

  response_models = {
    "application/json" = "Empty"
  }

  method_response {
    status_code = "200"

    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = true
      "method.response.header.Access-Control-Allow-Headers" = true
      "method.response.header.Access-Control-Allow-Methods" = true
    }
  }
}

data "aws_lambda_function" "login" {
  function_name = "login"
}

resource "aws_lambda_permission" "apigw_login" {
  statement_id  = "AllowAPIGatewayInvokeLogin-${random_string.suffix.result}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "integration_login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_login.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = data.aws_lambda_function.login.invoke_arn

  integration_response {
    status_code = "200"

    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin" = "'*'"
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
