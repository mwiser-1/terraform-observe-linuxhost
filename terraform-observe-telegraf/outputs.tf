output "events" {
  # this works around "var.events_dataset is null" error, but there's probably a more elegant way of doing this
  value = try(local.create_events_dataset ? observe_dataset.events[0] : var.events_dataset, observe_dataset.events[0])
}

output "host" {
  value = contains(var.create_resources, "host") ? observe_dataset.host[0] : null
}

output "volume" {
  value = contains(var.create_resources, "volume") ? observe_dataset.volume[0] : null
}

output "interface" {
  value = contains(var.create_resources, "interface") ? observe_dataset.interface[0] : null
}
