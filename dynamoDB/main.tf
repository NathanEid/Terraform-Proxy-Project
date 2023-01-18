resource "aws_dynamodb_table" "locks-dynamodb-table" {
  name           = var.table_name # "locks-dynamodb-table"
  hash_key       = var.table_hash_key# "LockId"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = var.attribute_name # "LockId"
    type = var.attribute_type # "S"
  }

  tags = {
    Name        = var.table_name # "locks-dynamodb-table"
  }
}