resource "aws_iam_role" "ex_role" {
  name = var.ex_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.ex_user}"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    Name = var.ex_role
  }
}

resource "aws_iam_role_policy" "ex_policy" {
  name = var.ex_role
  role = aws_iam_role.ex_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:lambda:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}"
      },
    ]
  })
}

resource "aws_iam_role" "rd_role" {
  name = var.rd_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.rd_user}"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    Name = var.rd_role
  }
}

resource "aws_iam_role_policy" "rd_policy" {
  name = var.rd_role
  role = aws_iam_role.rd_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
      },
    ]
  })
}

resource "aws_iam_role" "wr_role" {
  name = var.wr_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.wr_user}"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    Name = var.wr_role
  }
}

resource "aws_iam_role_policy" "wr_policy" {
  name = var.wr_role
  role = aws_iam_role.wr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
      },
    ]
  })
}