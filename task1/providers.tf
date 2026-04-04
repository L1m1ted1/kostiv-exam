terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  # Зберігання tfstate у хмарі (DigitalOcean Spaces сумісний з S3)
  backend "s3" {
    # ОНОВЛЕНО: Тепер використовуємо блок endpoints та обов'язково додаємо https://
    endpoints = {
      s3 = "https://kostiv-bucket.fra1.digitaloceanspaces.com"
    }
    region                      = "us-east-1" 
    bucket                      = "kostiv-bucket"
    key                         = "exam/terraform.tfstate"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    skip_region_validation      = true # Додано для більшої стабільності з DO
  }
}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}
