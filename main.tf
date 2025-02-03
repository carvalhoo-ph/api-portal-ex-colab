# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

provider "random" {
  # Configuração do provedor random1
}

// API Gateway Configuration
resource "aws_api_gateway_rest_api" "new_api" {
  name = "API_postar_ex-colab"
}

locals {
  api_id = aws_api_gateway_rest_api.new_api.id
  root_resource_id = aws_api_gateway_rest_api.new_api.root_resource_id
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = local.api_id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id

  lifecycle {
    ignore_changes = [deployment_id]
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = local.api_id

  depends_on = [
    aws_api_gateway_integration.integration_periodo_demonstrativo,
    aws_api_gateway_integration.integration_login,
    aws_api_gateway_integration.integration_demonstrativo_pgto
  ]
}

// Periodo Demonstrativo Lambda Integration
resource "aws_api_gateway_resource" "resource_periodo_demonstrativo" {
  rest_api_id = local.api_id
  parent_id   = local.root_resource_id
  path_part   = "periodo-demonstrativo"
}

resource "aws_api_gateway_method" "method_periodo_demonstrativo" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "method_response_periodo_demonstrativo" {
  rest_api_id = local.api_id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
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
  rest_api_id             = local.api_id
  resource_id             = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method             = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.periodo_demonstrativo.arn}/invocations"
}

resource "aws_api_gateway_integration_response" "integration_response_periodo_demonstrativo" {
  rest_api_id = local.api_id
  resource_id = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method = aws_api_gateway_method.method_periodo_demonstrativo.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_method_response.method_response_periodo_demonstrativo
  ]
}

resource "aws_api_gateway_method" "method_options_periodo_demonstrativo" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Access-Control-Request-Headers" = true,
    "method.request.header.Access-Control-Request-Method"  = true,
    "method.request.header.Origin"                         = true
  }
}

resource "aws_api_gateway_integration" "integration_options_periodo_demonstrativo" {
  rest_api_id             = local.api_id
  resource_id             = aws_api_gateway_resource.resource_periodo_demonstrativo.id
  http_method             = aws_api_gateway_method.method_options_periodo_demonstrativo.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

// Login Lambda Integration
resource "aws_api_gateway_resource" "resource_login" {
  rest_api_id = local.api_id
  parent_id   = local.root_resource_id
  path_part   = "login"
}

resource "aws_api_gateway_method" "method_login" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.resource_login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "method_response_login" {
  rest_api_id = local.api_id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_login.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
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
  rest_api_id             = local.api_id
  resource_id             = aws_api_gateway_resource.resource_login.id
  http_method             = aws_api_gateway_method.method_login.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.login.arn}/invocations"

  request_templates = {
    "application/json" = <<EOF
{
  "body": $input.json('$'),
  "headers": {
    #foreach($header in $input.params().header.keySet())
    "$header": "$util.escapeJavaScript($input.params().header.get($header))"
    #if($foreach.hasNext),#end
    #end
  },
  "queryStringParameters": {
    #foreach($queryParam in $input.params().querystring.keySet())
    "$queryParam": "$util.escapeJavaScript($input.params().querystring.get($queryParam))"
    #if($foreach.hasNext),#end
    #end
  },
  "pathParameters": {
    #foreach($pathParam in $input.params().path.keySet())
    "$pathParam": "$util.escapeJavaScript($input.params().path.get($pathParam))"
    #if($foreach.hasNext),#end
    #end
  }
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "integration_response_login" {
  rest_api_id = local.api_id
  resource_id = aws_api_gateway_resource.resource_login.id
  http_method = aws_api_gateway_method.method_login.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_method_response.method_response_login
  ]
}

resource "aws_api_gateway_method" "method_options_login" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.resource_login.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Access-Control-Request-Headers" = true,
    "method.request.header.Access-Control-Request-Method"  = true,
    "method.request.header.Origin"                         = true
  }
}

resource "aws_api_gateway_integration" "integration_options_login" {
  rest_api_id             = local.api_id
  resource_id             = aws_api_gateway_resource.resource_login.id
  http_method             = aws_api_gateway_method.method_options_login.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

// Demonstrativo Pgto Lambda Integration
resource "aws_api_gateway_resource" "resource_demonstrativo_pgto" {
  rest_api_id = local.api_id
  parent_id   = local.root_resource_id
  path_part   = "demonstrativo-pgto"
}

resource "aws_api_gateway_method" "method_demonstrativo_pgto" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.resource_demonstrativo_pgto.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "method_response_demonstrativo_pgto" {
  rest_api_id = local.api_id
  resource_id = aws_api_gateway_resource.resource_demonstrativo_pgto.id
  http_method = aws_api_gateway_method.method_demonstrativo_pgto.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

data "aws_lambda_function" "demonstrativo_pgto" {
  function_name = "demonstrativo-pgto"
}

resource "aws_api_gateway_integration" "integration_demonstrativo_pgto" {
  rest_api_id             = local.api_id
  resource_id             = aws_api_gateway_resource.resource_demonstrativo_pgto.id
  http_method             = aws_api_gateway_method.method_demonstrativo_pgto.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.demonstrativo_pgto.arn}/invocations"
}

resource "aws_api_gateway_integration_response" "integration_response_demonstrativo_pgto" {
  rest_api_id = local.api_id
  resource_id = aws_api_gateway_resource.resource_demonstrativo_pgto.id
  http_method = aws_api_gateway_method.method_demonstrativo_pgto.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
  }

  depends_on = [
    aws_api_gateway_method_response.method_response_demonstrativo_pgto
  ]
}

resource "aws_api_gateway_method" "method_options_demonstrativo_pgto" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.resource_demonstrativo_pgto.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Access-Control-Request-Headers" = true,
    "method.request.header.Access-Control-Request-Method"  = true,
    "method.request.header.Origin"                         = true
  }
}

resource "aws_api_gateway_integration" "integration_options_demonstrativo_pgto" {
  rest_api_id             = local.api_id
  resource_id             = aws_api_gateway_resource.resource_demonstrativo_pgto.id
  http_method             = aws_api_gateway_method.method_options_demonstrativo_pgto.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

// Remover duplicações dos recursos aws_lambda_permission

output "api_gateway_url" {
  value       = "https://${local.api_id}.execute-api.${var.region}.amazonaws.com/prod"
  description = "The URL of the API Gateway"
}
