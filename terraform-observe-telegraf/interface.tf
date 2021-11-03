resource "observe_dataset" "interface" {
  count       = contains(var.create_resources, "interface") ? 1 : 0
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Interface")
  icon_url    = "server"
  description = "Network interface resource generated from Telegraf net events"

  inputs = {
    "events" = observe_dataset.events[0].oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "net"
      make_col interface:string(tags.interface)
      filter not interface = "all"
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))}
      make_resource options(expiry:5m),
        primarykey(${join(", ", [for tag in var.extract_tags : tag])}, interface)
      set_label interface
    EOF
  }
}

resource "observe_link" "interface" {
  for_each = contains(var.create_resources, "interface") ? contains(var.create_resources, "host") ? {
    "host" : {
      "target" : observe_dataset.host[0].oid,
      "fields" : ["host", "datacenter"],
    }
  } : var.link_targets : {}

  workspace = var.workspace.oid
  source    = observe_dataset.interface[0].oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
