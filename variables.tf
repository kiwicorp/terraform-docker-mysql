# terraform-docker-mysql - variables.tf

variable "image_version" {
  type        = string
  description = <<-DESCRIPTION
  Container image version. This module uses the official 'mysql' Docker image.
  DESCRIPTION
  default     = "latest"
}

variable "start" {
  type        = bool
  description = "Whether to start the container or just create it."
  default     = true
}

variable "restart" {
  type        = string
  description = <<-DESCRIPTION
  The restart policy of the container. Must be one of: "no", "on-failure", "always",
  "unless-stopped".
  DESCRIPTION
  default     = "unless-stopped"
}

variable "create_data_volume" {
  type        = bool
  description = "Create a volume for the '/var/lib/mysql' directory."
  default     = true
}

variable "data_volume_name" {
  type        = string
  description = <<-DESCRIPTION
  The name of the data volume. If empty, a name will be automatically generated like this:
  'mysql_data_{random-uuid}'.
  DESCRIPTION
  default     = ""
}

variable "data_volume_driver" {
  type        = string
  description = "Storage driver for the data volume."
  default     = "local"
}

variable "data_volume_driver_opts" {
  type        = map(any)
  description = "Storage driver options for the data volume."
  default     = {}
}

variable "container_name" {
  type        = string
  description = <<-DESCRIPTION
  The name of the MySQL container. If empty, one will be generated like this:
  'mysql_{random-uuid}'.
  DESCRIPTION
  default     = ""
}

variable "labels" {
  type        = map(string)
  description = "Labels to attach to created resources that support labels."
  default     = {}
}

variable "config" {
  type = list(object({
    content  = string
    filename = string
  }))
  description = <<-DESCRIPTION
  A list of configuration files that should be uploaded inside the container.
  Each file will be uploaded to '/etc/mysql/conf.d/{filename}'.
  DESCRIPTION
  default     = []
  sensitive   = true
}

variable "init" {
  type = list(object({
    filename    = string
    source      = string
    source_hash = string
  }))
  description = <<-DESCRIPTION
  A list of init files that should be uploaded inside the container.
  Each file will be uploaded to '/docker-entrypoint-initdb.d/{filename}'.
  DESCRIPTION
  default     = []
  sensitive   = true
}

variable "internal_port" {
  type        = number
  description = <<-DESCRIPTION
  MySQL internal port. Should be the same as the one specified in the
  configuration.
  DESCRIPTION
  default     = 6379
}

variable "external_port" {
  type        = number
  description = <<-DESCRIPTION
  MySQL external port. Should be the same as the one specified in the
  configuration. Set this to 0 for automatic port allocation.
  DESCRIPTION
  default     = 6379
}

variable "ip" {
  type        = string
  description = "Ip address to bind the container port to."
  default     = "127.0.0.1"
}

variable "uuid" {
  type        = string
  description = <<-DESCRIPTION
  Uuid to use when naming the resources created by this volume. If empty, an
  uuid will be generated instead.
  DESCRIPTION
  default     = ""
}

variable "mysql_root_password" {
  type        = string
  description = "MySQL root password."
  default     = ""
  sensitive   = true
}

variable "mysql_database" {
  type        = string
  description = "MySQL database name."
  default     = ""
}

variable "mysql_user" {
  type        = string
  description = "Name of the user that should be created."
  default     = ""
}

variable "mysql_password" {
  type        = string
  description = "Password of the user that should be created."
  default     = ""
}

variable "mysql_allow_empty_password" {
  type        = bool
  description = "Whether an empty root password should be allowed or not."
  default     = false
}

variable "mysql_random_root_password" {
  type        = bool
  description = "Whether to create a randomized password for the root user."
  default     = false
}

variable "mysql_onetime_password" {
  type        = bool
  description = <<-DESCRIPTION
  Set root user as expired after init, forcing a password change on first login.
  DESCRIPTION
  default     = false
}

variable "mysql_initdb_skip_tzinfo" {
  type        = bool
  description = "Disable timezone loading."
  default     = false
}
