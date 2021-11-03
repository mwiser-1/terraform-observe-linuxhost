output "events" {
  # this works around "var.events_dataset is null" error, but there's probably a more elegant way of doing this
  value = try(local.create_events_dataset ? observe_dataset.events[0] : var.events_dataset, observe_dataset.events[0])
}

output "host" {
  value = contains(var.create_resources, "host") ? observe_dataset.host[0] : null
}

output "log_file" {
  value = contains(var.create_resources, "log_file") ? observe_dataset.log_file[0] : null
}
