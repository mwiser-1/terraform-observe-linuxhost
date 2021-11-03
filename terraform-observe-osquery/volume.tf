resource "observe_dataset" "volume" {
  count       = contains(var.create_resources, "volume") ? 1 : 0
  workspace   = var.workspace.oid
  name        = format(var.resource_name_format, "Volume")
  icon_url    = "server"
  description = "Volume resource generated from OSQuery mounts_snapshot events"

  inputs = {
    "event" = observe_dataset.events[0].oid
  }

  stage {
    input    = "event"
    pipeline = <<-EOF
      filter name = "mounts_snapshot"
      flatten_single log.snapshot
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))},
        volume:regex_replace(string(@."_c_log_snapshot_value".device_alias), /\/dev\//, ""),
        path:string(@."_c_log_snapshot_value".path),
        device:string(@."_c_log_snapshot_value".device),
        type:string(@."_c_log_snapshot_value".type),
        blocks:int64(@."_c_log_snapshot_value".blocks),
        blocks_size:int64(@."_c_log_snapshot_value".blocks_size),
        flags:string(@."_c_log_snapshot_value".flags)
      make_resource options(expiry:5m),
        device,
        path,
        type,
        flags,
        primarykey(${join(", ", [for tag in var.extract_tags : tag])}, volume)
      set_label volume
    EOF
  }
}

resource "observe_link" "volume" {
  for_each = contains(var.create_resources, "volume") ? contains(var.create_resources, "host") ? {
    "host" : {
      "target" : observe_dataset.host[0].oid,
      "fields" : [for tag in var.extract_tags : format("%s", tag)],
    }
  } : var.link_targets : {}

  workspace = var.workspace.oid
  source    = observe_dataset.volume[0].oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
