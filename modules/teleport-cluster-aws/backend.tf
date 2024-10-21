/*
DynamoDB is used to store cluster state, event
metadata, and a simple locking mechanism for SSL
cert generation and renewal.
*/

// DynamoDB table for storing cluster state
resource "aws_dynamodb_table" "teleport_backend" {
  name           = "${var.eks_cluster_name}-backend"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "HashKey"
  range_key      = "FullPath"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity,
    ]
  }

  attribute {
    name = "HashKey"
    type = "S"
  }

  attribute {
    name = "FullPath"
    type = "S"
  }

  stream_enabled   = "true"
  stream_view_type = "NEW_IMAGE"

  ttl {
    attribute_name = "Expires"
    enabled        = true
  }

  tags = {
    TeleportCluster = var.eks_cluster_name
  }
}

// DynamoDB table for storing cluster events
resource "aws_dynamodb_table" "teleport_events" {
  name           = "${var.eks_cluster_name}-events"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "SessionID"
  range_key      = "EventIndex"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  global_secondary_index {
    name            = "timesearchV2"
    hash_key        = "CreatedAtDate"
    range_key       = "CreatedAt"
    write_capacity  = 10
    read_capacity   = 10
    projection_type = "ALL"
  }

  lifecycle {
    ignore_changes = all
  }

  attribute {
    name = "SessionID"
    type = "S"
  }

  attribute {
    name = "EventIndex"
    type = "N"
  }

  attribute {
    name = "CreatedAtDate"
    type = "S"
  }

  attribute {
    name = "CreatedAt"
    type = "N"
  }

  ttl {
    attribute_name = "Expires"
    enabled        = true
  }

  tags = {
    TeleportCluster = var.eks_cluster_name
  }
}
