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

resource "aws_api_gateway_rest_api" "MyApi" {
  name = "MyApi"
  // ...existing code...
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

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
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method             = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.periodo_demonstrativo.invoke_arn
}

resource "aws_api_gateway_integration_response" "integration_response_periodo_demonstrativo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_method_response.method_response_periodo_demonstrativo
  ]
}

resource "aws_api_gateway_method" "method_options_periodo_demonstrativo" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration_options_periodo_demonstrativo" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method             = aws_api_gateway_method.method_options_periodo_demonstrativo.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "method_response_options_periodo_demonstrativo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_options_periodo_demonstrativo.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }

  response_models = {
    "application/json" = "Empty"
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
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource_login.id
  http_method             = aws_api_gateway_method.method_login.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.login.invoke_arn
}

resource "aws_api_gateway_integration_response" "integration_response_login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_login.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_method_response.method_response_login
  ]
}

resource "aws_api_gateway_method" "method_options_login" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource_login.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration_options_login" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource_login.id
  http_method             = aws_api_gateway_method.method_options_login.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "method_response_options_login" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_options_login.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_resource" "MyApiResource" {
  rest_api_id = aws_api_gateway_rest_api.MyApi.id
  parent_id   = aws_api_gateway_rest_api.MyApi.root_resource_id
  path_part   = "myresource"
}

resource "aws_api_gateway_method" "MyApiMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyApi.id
  resource_id   = aws_api_gateway_resource.MyApiResource.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration" "MyApiIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.MyApi.id
  resource_id             = aws_api_gateway_resource.MyApiResource.id
  http_method             = aws_api_gateway_method.MyApiMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:MyFunction/invocations"
}

resource "aws_api_gateway_method_response" "MyApiMethodResponse" {
  rest_api_id = aws_api_gateway_rest_api.MyApi.id
  resource_id = aws_api_gateway_resource.MyApiResource.id
  http_method = aws_api_gateway_method.MyApiMethod.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
}

resource "aws_api_gateway_method" "MyApiOptionsMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyApi.id
  resource_id   = aws_api_gateway_resource.MyApiResource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "MyApiOptionsIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.MyApi.id
  resource_id             = aws_api_gateway_resource.MyApiResource.id
  http_method             = aws_api_gateway_method.MyApiOptionsMethod.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  integration_response {
    status_code = "200"

    response_parameters = {
      "method.response.header.Access-Control-Allow-Origin"  = "'*'"
      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    }
  }
}

resource "aws_api_gateway_method_response" "MyApiOptionsMethodResponse" {
  rest_api_id = aws_api_gateway_rest_api.MyApi.id
  resource_id = aws_api_gateway_resource.MyApiResource.id
  http_method = aws_api_gateway_method.MyApiOptionsMethod.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
}
