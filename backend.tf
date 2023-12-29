# terraform {
#   backend "s3" {
#     bucket         = "Add-your-bucket-name"
#     key            = "terraform.tfstate"
#     region         = var.region
#     dynamodb_table = "your-dynamo-table-name"
#   }
# }