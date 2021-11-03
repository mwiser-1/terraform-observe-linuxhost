variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "name_format" {
  type        = string
  description = "Format string to use for dataset names. Override to introduce a prefix or suffix."
  default     = "%s"
}

variable "fluentbit" {
  description = "Fluentbit module"
  type = object({
    events = object({ oid = string })
  })
}

variable "extract_tags" {
  description = "Additional tags to extract as columns."
  type        = list(string)
  default     = []
}

variable "link_targets" {
  description = "Datasets to link to."
  type = map(object({
    target = string
    fields = list(string)
  }))
  default = {}
}
