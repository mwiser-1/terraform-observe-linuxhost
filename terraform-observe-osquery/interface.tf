resource "observe_dataset" "interface" {
  count       = contains(var.create_resources, "interface") ? 1 : 0
  workspace   = var.workspace.oid
  name        = format(var.resource_name_format, "Interface")
  icon_url    = "server"
  description = "Interface resource generated from OSQuery interfaces_snapshot events"

  inputs = {
    "event" = observe_dataset.events[0].oid
  }

  stage {
    input    = "event"
    pipeline = <<-EOF
      filter name = "interfaces_snapshot"
      flatten_single log.snapshot
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))},
        interface:string(@."_c_log_snapshot_value".interface),
        mac_address:string(@."_c_log_snapshot_value".mac),
        link_speed:string(@."_c_log_snapshot_value".link_speed),
        mtu:string(@."_c_log_snapshot_value".mtu),
        flags:string(@."_c_log_snapshot_value".flags),
        type:int64(@."_c_log_snapshot_value".type)
      make_resource options(expiry:5m),
        mac_address,
        link_speed,
        mtu,
        flags,
        primarykey(${join(", ", [for tag in var.extract_tags : tag])}, interface)
      set_label interface
    EOF
  }
}

resource "observe_link" "interface" {
  for_each = contains(var.create_resources, "interface") ? contains(var.create_resources, "host") ? {
    "host" : {
      "target" : observe_dataset.host[0].oid,
      "fields" : [for tag in var.extract_tags : format("%s", tag)],
    }
  } : var.link_targets : {}

  workspace = var.workspace.oid
  source    = observe_dataset.interface[0].oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
