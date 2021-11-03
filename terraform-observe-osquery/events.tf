locals {
  create_events_dataset = var.events_dataset == null
}

resource "observe_dataset" "events" {
  count = local.create_events_dataset ? 1 : 0

  workspace = var.workspace.oid
  name      = format(var.name_format, "Events")
  icon_url  = "chromatography"

  description = <<-EOF
    This dataset contains raw osquery events, from which metric datasets can
    be derived.
  EOF

  inputs = {
    "observation" = data.observe_dataset.observation.oid
  }

  stage {
    input    = "observation"
    pipeline = <<-EOF
      filter OBSERVATION_KIND = "http" and string(EXTRA.path) = "${var.path}"
      make_col log:parsejson(string(FIELDS.log))
      make_col timestamp:seconds(int64(log.unixTime)), name:string(log.name), tags:makeobject()
      ${join("\n\n", [for key in var.merge_tags : indent(2, format("make_col tags:make_fields(tags, %s:string(FIELDS.%s))", key, key))])}
      set_valid_from options(max_time_diff:${var.max_time_diff}), timestamp
      pick_col
        timestamp,
        name,
        tags,
        log
    EOF
  }
}
