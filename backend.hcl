bucket         = "your-terraform-state-bucket"
dynamodb_table = "your-terraform-lock-table"
key            = "path/to/your/terraform.tfstate"
encrypt        = true
region         = "us-east-1"
allowed_account_ids = ["123456789012"]
