output "vm1_gateway_name" {
  description = "Name of VM1 gateway"
  value       = virtualbox_vm.vm1_gateway.name
}

output "vm2_appserver_name" {
  description = "Name of VM2 app server"
  value       = virtualbox_vm.vm2_appserver.name
}