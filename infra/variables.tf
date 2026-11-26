variable "allowed_ips" {
  description = "عناوين IP المسموح لها بالدخول على SSH وKubernetes API"
  type        = list(string)

  validation {
    condition     = alltrue([for ip in var.allowed_ips : can(cidrnetmask(ip))])
    error_message = "كل عنوان لازم يكون بالشكل ده: 1.2.3.4/32"
  }
}

variable "ssh_public_key_path" {
  description = "مسار المفتاح العام (.pub) على جهازك"
  type        = string
  default     = "~/.ssh/rowad-key.pub"
}