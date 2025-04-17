# API Gateway
resource "aws_api_gateway_rest_api" "visitor_counter" {
  name        = "visitor-counter-api"
  description = "API for visitor counter"
}

# API Gateway Resource
resource "aws_api_gateway_resource" "visitor_count" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  parent_id   = aws_api_gateway_rest_api.visitor_counter.root_resource_id
  path_part   = "visitor-count"
}

# POST Method
resource "aws_api_gateway_method" "post_count" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter.id
  resource_id   = aws_api_gateway_resource.visitor_count.id
  http_method   = "POST"
  authorization = "NONE"
}

# Enable CORS
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter.id
  resource_id   = aws_api_gateway_resource.visitor_count.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Integration with DynamoDB
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_counter.id
  resource_id             = aws_api_gateway_resource.visitor_count.id
  http_method             = aws_api_gateway_method.post_count.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter.invoke_arn
}

# CORS Integration Response
resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method Response for POST
resource "aws_api_gateway_method_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.post_count.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Method Response for OPTIONS
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Max-Age"       = true
  }
}

# Integration Response for OPTIONS
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'https://www.skillspheres.com'"
    "method.response.header.Access-Control-Max-Age"       = "'7200'"
  }
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id

  triggers = {
    # Add a trigger to force redeployment
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.visitor_count,
      aws_api_gateway_method.options,
      aws_api_gateway_integration.options,
      aws_api_gateway_integration_response.options,
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.get_lambda, # Add this line
    aws_api_gateway_integration.options,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Stage
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter.id
  stage_name    = "dev"
}

# Lambda Permission
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_counter.execution_arn}/*/*"
}


# GET Method
resource "aws_api_gateway_method" "get_count" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter.id
  resource_id   = aws_api_gateway_resource.visitor_count.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET Integration (same Lambda)
resource "aws_api_gateway_integration" "get_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_counter.id
  resource_id             = aws_api_gateway_resource.visitor_count.id
  http_method             = aws_api_gateway_method.get_count.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter.invoke_arn
}

# GET Method Response
resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.get_count.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# POST Integration Response
resource "aws_api_gateway_integration_response" "post" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.post_count.http_method
  status_code = aws_api_gateway_method_response.post_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://www.skillspheres.com'"
  }

  depends_on = [
    aws_api_gateway_integration.lambda
  ]
}

# Uncomment and update the GET Integration Response
resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.get_count.http_method
  status_code = aws_api_gateway_method_response.get_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://www.skillspheres.com'"
  }

  depends_on = [
    aws_api_gateway_integration.get_lambda
  ]
}


/*
# GET Integration Response
resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.get_count.http_method
  status_code = aws_api_gateway_method_response.get_200.status_code

  depends_on = [
    aws_api_gateway_integration.get_lambda
  ]
}
*/