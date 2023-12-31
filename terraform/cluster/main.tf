## Azure storage account for storing tfstate remotely ##
# resource "azurerm_storage_account" "tfstate" {
#   name = "tfstate${random_string.resource_code.result}"
#   resource_group_name = var.resource_group_name.name
#   location = var.location
#   account_tier = "Standard"
#   account_replication_type = "LRS"
#   allow_nested_items_to_be_public = false

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_storage_container" "tfstate" {
#   name = "tfstate"
#   storage_account_name = azurerm_storage_account.tfstate.name
#   container_access_type = "private"
# }

## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "aks_demo" { 
  name = var.cluster_name
  resource_group_name = var.resource_group_name.name
  location = var.location
  dns_prefix = var.dns_prefix

  linux_profile {
    admin_username = var.admin_username

    ## SSH key is generated using "tls_private_key" resource
    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@azure.com"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
    EOF
  }
}

## Outputs ##

# Example attributes available for output
output "id" {
    value = azurerm_kubernetes_cluster.aks_demo.id
}

output "client_key" {
  value = azurerm_kubernetes_cluster.aks_demo.kube_config[0].client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks_demo.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks_demo.kube_config.0.cluster_ca_certificate
}

output "kube_config" {
  sensitive = true
  value = azurerm_kubernetes_cluster.aks_demo.kube_config_raw
}

output "host" {
  value = azurerm_kubernetes_cluster.aks_demo.kube_config.0.host
}

output "configure" {
  sensitive = true
  value = <<CONFIGURE

    Run the following commands to configure kubernetes client:

    $ terraform output kube_config > ~/.kube/aksconfig
    $ export KUBECONFIG=~/.kube/aksconfig

    Test configuration using kubectl

    $ kubectl get nodes
    CONFIGURE
}