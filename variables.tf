variable "agents" {
  type        = map(bool)
  description = "This is used to find associated boards - including or excluding metrics (Telegraf)"
  default     = {
    telegraf = true
  }
}
variable "observe_workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}
variable "enable_telegraf" {
  type        = bool
  default     = false
}

variable "observation_dataset" {
  type        = string
  description = "Name of dataset to derive kubernetes resources from."
  default     = "Observation"
}

variable "max_expiry" {
  type        = number
  description = "Maximum expiry time for resources in minutes."
  default     = 90
}

variable "freshness_overrides" {
  type        = map(string)
  description = "Freshness overrides by dataset. If absent, fall back to freshness_default"
  default     = {}
}

variable "freshness_default" {
  type        = string
  description = "Default dataset freshness. Can be overridden with freshness input"
  default     = "1m"
}

