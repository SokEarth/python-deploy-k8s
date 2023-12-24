## Azure config variables ##
variable location {
  type = string
}

variable resource_group_name {
  type = string
  default = "py-ty-terraform"
}

variable storage_account_name {
  type = string
  default = "main"
}

variable storage_container_name {
  type = string
  default = "tfstate"
}

variable SUBSCRIPTION_ID {}
variable TENANT_ID {}
variable CLIENT_ID {}
variable CLIENT_SECRET {}

## AKS kubernetes cluster variables ##
variable cluster_name {
  default = "aksdemo1"
}

variable agent_count {
  default = 3
}

variable dns_prefix {
  default = "aksdemo"
}

variable admin_username {
  default = "demo"
}