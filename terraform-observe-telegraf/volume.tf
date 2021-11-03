resource "observe_dataset" "volume" {
  count       = contains(var.create_resources, "volume") ? 1 : 0
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Volume")
  icon_url    = "server"
  description = "Volume resource generated from Telegraf disk events"

  inputs = {
    "events" = observe_dataset.events[0].oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "disk"
      make_col volume:string(tags.device)
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))}
      make_resource options(expiry:5m),
        primarykey(${join(", ", [for tag in var.extract_tags : tag])}, volume)
      set_label volume
    EOF
  }
}

resource "observe_link" "volume" {
  for_each = contains(var.create_resources, "volume") ? contains(var.create_resources, "host") ? {
    "host" : {
      "target" : observe_dataset.host[0].oid,
      "fields" : ["host", "datacenter"],
    }
  } : var.link_targets : {}

  workspace = var.workspace.oid
  source    = observe_dataset.volume[0].oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
