resource "observe_dataset" "log_file" {
  count       = contains(var.create_resources, "log_file") ? 1 : 0
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Log File")
  icon_url    = "audio-file"
  description = "Tailed Log File"

  inputs = {
    "events" = observe_dataset.events[0].oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter string(inputType) = "/fluentbit/tail"
      make_col
        path:string(event["path"]),
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))}
      make_resource options (expiry:${var.max_expiry}),
        primarykey(${join(", ", [for tag in var.extract_tags : tag])}, path)
      set_label path
    EOF
  }
}

resource "observe_link" "log_file" {
  for_each = contains(var.create_resources, "log_file") ? contains(var.create_resources, "host") ? {
    "host" : {
      "target" : observe_dataset.host[0].oid,
      "fields" : ["host", "datacenter"],
    }
  } : var.link_targets : {}

  workspace = var.workspace.oid
  source    = observe_dataset.log_file[0].oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
