variable "service_name" {
  type    = string
  default = "differ"
}

variable "env" {
  type = string
}

variable "app_port" {
  type    = number
  default = 4567
}

variable "cpu_limit" {
  type    = number
  default = 20
}

variable "mem_limit" {
  type    = number
  default = 256
}

variable "mem_reservation" {
  type    = number
  default = 32
}

variable "TAGGED_IMAGE" {
  type = string
}

# App variables
variable "app_env_vars" {
  type = map(any)
  default = {
    CYBER_DOJO_PROMETHEUS     = "false"
    CYBER_DOJO_DIFFER_PORT    = "4567"
    CYBER_DOJO_SAVER_PORT     = "4537"
    CYBER_DOJO_SAVER_HOSTNAME = "saver.cyber-dojo.eu-central-1"
  }
}

variable "ecr_replication_targets" {
  type    = list(map(string))
  default = []
}

variable "ecr_replication_origin" {
  type    = string
  default = ""
}
