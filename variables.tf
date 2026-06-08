variable "sa-id" {
    type = string
}

variable "yc_token" { type = string }
variable "yc_cloud_id" { type = string }
variable "yc_folder_id" { type = string }
variable "ssh_public_key_path" {
  type        = string
  description = "Путь к публичному SSH-ключу"
  default     = "~/.ssh/id_rsa.pub"
}
