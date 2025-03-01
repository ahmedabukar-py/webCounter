# Create DynamoDB Table
resource "aws_dynamodb_table" "visitor_counts" {
  name           = "VisitorCounts"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand pricing
  hash_key       = "PageID"
  
  attribute {
    name = "PageID"
    type = "S"  # String type
  }

  # Optional: Add timestamp attribute for when counts were last updated
  attribute {
    name = "LastUpdated"
    type = "S"
  }

  # Optional: Global Secondary Index for querying by timestamp
  global_secondary_index {
    name               = "LastUpdatedIndex"
    hash_key          = "LastUpdated"
    projection_type    = "ALL"
  }
}


# Create IAM Role
resource "aws_iam_role" "dynamodb_role" {
  name = "visitor_counter_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"  # Adjust based on your needs (e.g., EC2, Lambda)
        }
      }
    ]
  })

  tags = {
    Name = "visitor_counter_role"
  }
}

# Create IAM Policy for DynamoDB access
resource "aws_iam_policy" "dynamodb_policy" {
  name        = "visitor_counter_policy"
  description = "Policy for DynamoDB visitor counter access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.visitor_counts.arn,
          "${aws_dynamodb_table.visitor_counts.arn}/index/*"  # Include GSI access
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "dynamodb_policy_attach" {
  role       = aws_iam_role.dynamodb_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}
