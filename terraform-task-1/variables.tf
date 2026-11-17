###cloud vars

variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "ssh_public_key" {
  type        = string
  description = "Содержимое публичного SSH ключа"
}

###network var

variable "nat_image_id" {
  description = "Image ID для NAT инстанса"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}

###vm var

variable "vm_preemptible" {
  type        = bool
  default     = true
}