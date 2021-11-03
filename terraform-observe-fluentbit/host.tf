resource "observe_dataset" "host" {
  count       = contains(var.create_resources, "host") ? 1 : 0
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Host")
  icon_url    = "server"
  description = "Host resource generated from Fluentbit"

  inputs = {
    "event" = observe_dataset.events[0].oid
  }

  stage {
    input    = "event"
    pipeline = <<-EOF
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))}
      make_resource options(expiry:${var.max_expiry}),
        primarykey(${join(", ", [for tag in var.extract_tags : tag])})
      set_label host
    EOF
  }
}

