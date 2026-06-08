terraform {
  required_providers {
    yandex = {
        source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
    token     = var.token
    cloud_id  = var.cloud-id
    folder_id = var.folder-id
    zone      = "ru-central1-a"
}

resource "yandex_iam_service_account" "sa" {
  name        = var.name
  description = var.description
  folder_id   = var.folder-id
}

resource "yandex_resourcemanager_folder_iam_member" "sa_editor" {
  folder_id = var.folder-id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_key" "sa_json_key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "JSON key for Gitea Actions CI/CD"
}

output "service_account_id" {
  value = yandex_iam_service_account.sa.id
}

output "sa_json_key_content" {
  description = "Содержимое JSON-ключа для авторизации"
  value       = yandex_iam_service_account_key.sa_json_key.private_key
  sensitive   = true # скрывает ключ от случайного отображения на экране
}
