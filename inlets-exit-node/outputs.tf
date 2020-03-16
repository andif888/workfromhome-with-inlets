output "inlets_authtoken" {
    description = "Inlets server authentication token"
    value = var.inlets_authtoken
}
output "inlets_client_commandline" {
    description = "Use this command to run inlets client"
    value = "inlets client --remote wss://${azurerm_public_ip.vm.fqdn} --upstream=${azurerm_public_ip.vm.fqdn}=http://127.0.0.1:8081 --token=${var.inlets_authtoken}"
}
output "vm_admin_username" {
    description = "Admin username to logon to the VM"
    value = var.admin_username
}
output "vm_admin_password" {
    description = "Admin password to logon to the VM"
    value = var.admin_password
}
output "vm_fqdn" {
  description = "fqdn to connect to the vm provisioned."
  value       = azurerm_public_ip.vm.fqdn
}
output "vm_ids" {
  description = "Virtual machine ids created."
  value       = azurerm_virtual_machine.vm-linux.id
}
output "vm_public_ip" {
  description = "The actual ip address allocated for the resource."
  value       = azurerm_public_ip.vm.ip_address
}
output "vm_ssh_connect_command" {
    description="Use this command to connect using SSH"
    value = "ssh ${var.admin_username}@${azurerm_public_ip.vm.fqdn}"
}