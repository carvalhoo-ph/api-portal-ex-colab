provider "aws" {
  region = "us-east-1"
}

provider "random" {
  # Configuração do provedor random
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "API_postar_ex-colab"
  description = "API Gateway for my application"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "resource"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}
