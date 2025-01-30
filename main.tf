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

resource "aws_api_gateway_stage" "stage" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.integration_periodo_demonstrativo,
    aws_api_gateway_integration.integration_login
  ]
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
}

resource "aws_api_gateway_method_response" "method_response_periodo_demonstrativo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

data "aws_lambda_function" "periodo_demonstrativo" {
  function_name = "periodo-demonstrativo"
}

resource "aws_api_gateway_integration" "integration_periodo_demonstrativo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = data.aws_lambda_function.periodo_demonstrativo.invoke_arn
}

resource "aws_api_gateway_integration_response" "integration_response_periodo_demonstrativo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.integration_periodo_demonstrativo
  ]
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
}

resource "aws_api_gateway_method_response" "method_response_login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_login.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

data "aws_lambda_function" "login" {
  function_name = "login"
}

resource "aws_api_gateway_integration" "integration_login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_login.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = data.aws_lambda_function.login.invoke_arn
}

resource "aws_api_gateway_integration_response" "integration_response_login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_login.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_integration.integration_login
  ]
}
