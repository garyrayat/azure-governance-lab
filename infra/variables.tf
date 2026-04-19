variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "East US"
}

variable "required_tags" {
  type    = list(string)
  default = ["environment", "owner", "cost_center"]
}
