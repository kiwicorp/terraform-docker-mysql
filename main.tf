# terraform-docker-mysql - main.tf

resource "random_uuid" "this" {}

data "docker_registry_image" "this" {
  name = "mysql:${var.image_version}"
}

resource "docker_image" "this" {
  name          = data.docker_registry_image.this.name
  pull_triggers = [data.docker_registry_image.this.sha256_digest]
}

resource "docker_volume" "data" {
  count = var.create_data_volume ? 1 : 0

  name        = local.data_volume_name
  driver      = var.data_volume_driver
  driver_opts = var.data_volume_driver_opts

  dynamic "labels" {
    for_each = var.labels
    iterator = label
    content {
      label = label.key
      value = label.value
    }
  }
}

resource "docker_container" "this" {
  name  = local.container_name
  image = docker_image.this.latest

  env = local.env

  ports {
    internal = var.internal_port
    external = var.external_port
    protocol = "tcp"
    ip       = var.ip
  }

  # upload configuration files
  dynamic "upload" {
    for_each = local.config
    iterator = upload
    content {
      file    = upload.value.filename
      content = upload.value.content
    }
  }

  # upload init files
  dynamic "upload" {
    for_each = local.init
    iterator = upload
    content {
      file        = upload.value.filename
      source      = upload.value.source
      source_hash = upload.value.source_hash
    }
  }

  # data volume
  dynamic "volumes" {
    for_each = docker_volume.data
    iterator = volume
    content {
      volume_name    = volume.value.name
      container_path = "/var/lib/mysql"
    }
  }

  dynamic "labels" {
    for_each = var.labels
    iterator = label
    content {
      label = label.key
      value = label.value
    }
  }

  must_run = true
  restart  = var.restart
  start    = var.start
}

locals {
  uuid = var.uuid != "" ? var.uuid : random_uuid.this.result

  data_volume_name = var.create_data_volume ? (
    var.data_volume_name != "" ? var.data_volume_name : (
      "mysql_data_${local.uuid}"
    )
  ) : ""

  container_name = var.container_name != "" ? var.container_name : (
    "mysql_${local.uuid}"
  )

  config = [for _, v in var.config: {
    file    = "/etc/mysql/conf.d/${v.filename}"
    content = v.content
  }]

  env_map = {
    MYSQL_ROOT_PASSWORD        = var.mysql_root_password
    MYSQL_DATABASE             = var.mysql_database
    MYSQL_USER                 = var.mysql_user
    MYSQL_PASSWORD             = var.mysql_password
    MYSQL_ALLOW_EMPTY_PASSWORD = var.mysql_allow_empty_password ? "yes" : ""
    MYSQL_RANDOM_ROOT_PASSWORD = var.mysql_random_root_password ? "yes" : ""
    MYSQL_ONETIME_PASSWORD     = var.mysql_onetime_password ? "yes" : ""
    MYSQL_INITDB_SKIP_TZINFO   = var.mysql_initdb_skip_tzinfo ? "yes" : ""
  }

  env = [for k, v in local.env_map : format("%s=%s", k, v) if v != ""]

  init = [for _, v in var.init : {
    filename    = "/docker-entrypoint-initdb.d/${v.filename}"
    source      = v.source
    source_hash = filesha256(v.source)
  }]
}
