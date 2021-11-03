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
