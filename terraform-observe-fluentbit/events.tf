locals {
  create_events_dataset = var.events_dataset == null
}

resource "observe_dataset" "events" {
  count = local.create_events_dataset ? 1 : 0

  workspace   = var.workspace.oid
  name        = format(var.name_format, "Events")
  icon_url    = "filing-cabinet"
  description = <<-EOF
    This dataset contains raw fluentbit events, from which other datasets can
    be derived.
  EOF

  inputs = {
    "observation" = data.observe_dataset.observation.oid
  }

  stage {
    input    = "observation"
    pipeline = <<-EOF
      filter OBSERVATION_KIND = "http" and string(EXTRA.path) ~ /fluentbit/
      make_col
        timestamp:timestamp_ns(int64(FIELDS.fluentTimestamp)),
        inputType:string(EXTRA.path),
        name:string(FIELDS.host),
        tags:makeobject()

      set_valid_from options(max_time_diff:${var.max_time_diff}), timestamp
      ${join("\n\n", [for key in var.merge_tags : indent(2, format("make_col tags:make_fields(tags, %s:string(FIELDS.%s))", key, key))])}

      pick_col
        timestamp,
        inputType,
        name,
        event:FIELDS,
        tags
    EOF
  }
}
