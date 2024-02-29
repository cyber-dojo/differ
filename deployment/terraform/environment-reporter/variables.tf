variable "kosli_hosts" {
  type = map(any)
  default = {
    staging = "https://staging.app.kosli.com"
    prod    = "https://app.kosli.com"
  }
}

variable "env" {
  type = string
}
