terraform {
  required_providers {
    observe = {
      source  = "terraform.observeinc.com/observeinc/observe"
      version = "~> 0.4.0"
    }
  }
}

locals {
  extract_tags = ["host", "datacenter"]
  link_targets = {
    "Host": {
      "target": module.osquery.host.oid,
      "fields": ["host", "datacenter"],
    }
  }
  telegraf_name_format  = "Telegraf/%s"
  fluentbit_name_format = "Fluentbit/%s"
  osquery_name_format   = "OSQuery/%s"

  enable_telegraf       = lookup(var.agents, "telegraf", false)
}

module "osquery" {
  source            = "git::https://github.com/observeinc/terraform-observe-osquery.git"
  
  workspace         = var.observe_workspace
  create_resources  = ["host", "volume", "interface", "users"]
  merge_tags        = ["host", "datacenter"]
  link_targets      = {
    "Host": {
      "target": module.osquery.host.oid,
      "fields": ["host", "datacenter"],
    }
  }
  path              = "/fluentbit/tail"
  name_format       = local.osquery_name_format
}

module "osquery_shell_history" {
  source            = "git::https://github.com/observeinc/terraform-observe-osquery.git//inputs/shell_history"
  workspace         = var.observe_workspace
  osquery           = module.osquery
  extract_tags      = ["host", "datacenter"]
  link_targets      = merge(local.link_targets,
    {
      "users": {
        "target": module.osquery.users.oid,
        "fields": ["host", "datacenter", "uid"],
      }
    }
  )
  name_format       = local.osquery_name_format
}

module "fluentbit" {
  source            = "git::https://github.com/observeinc/terraform-observe-fluentbit.git"

  workspace         = var.observe_workspace
  create_resources  = ["log_file"]
  merge_tags        = ["host", "datacenter"]
  link_targets      = {
    "Host": {
      "target": module.osquery.host.oid,
      "fields": ["host", "datacenter"],
    }
  }
  path              = "/fluentbit"
  name_format       = local.fluentbit_name_format
}

module "fluentbit_tail" {
  source            = "git::https://github.com/observeinc/terraform-observe-fluentbit.git//inputs/tail"
  workspace         = var.observe_workspace
  fluentbit         = module.fluentbit
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.fluentbit_name_format
}

module "fluentbit_systemd" {
  source            = "git::https://github.com/observeinc/terraform-observe-fluentbit.git//inputs/systemd"
  workspace         = var.observe_workspace
  fluentbit         = module.fluentbit
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.fluentbit_name_format
}

module "telegraf" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git"
  workspace         = var.observe_workspace
  create_resources  = []
  link_targets      = {
    "Host": {
      "target": module.osquery.host.oid,
      "fields": ["host", "datacenter"],
    }
  }
  path              = "/telegraf"
  name_format       = local.telegraf_name_format
}

module "telegraf_cpu" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/cpu"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_diskio" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/diskio"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_mem" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/mem"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_disk" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/disk"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = merge(local.link_targets,
    {
      "volume": {
        "target": module.osquery.volume.oid,
        "fields": ["host", "datacenter", "volume"],
      }
    }
  )
  name_format       = local.telegraf_name_format
}

module "telegraf_kernel" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/kernel"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_processes" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/processes"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_swap" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/swap"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_system" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/system"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_ntpq" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/ntpq"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_linux_sysctl_fs" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/linux_sysctl_fs"
  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = local.link_targets
  name_format       = local.telegraf_name_format
}

module "telegraf_net" {
  count           = local.enable_telegraf ? 1 : 0
  source            = "git::https://github.com/observeinc/terraform-observe-telegraf.git//inputs/net"

  workspace         = var.observe_workspace
  telegraf          = module.telegraf[0]
  extract_tags      = local.extract_tags
  link_targets      = merge(local.link_targets,
    {
      "interface": {
        "target": module.osquery.interface.oid,
        "fields": ["host", "datacenter", "interface"],
      }
    }
  )
  name_format       = local.telegraf_name_format
}

resource "observe_board" "host_board_metrics" {
  count           = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.host.oid
  name    = "Linux Host Summary - BetaBoard with Metrics"
  type    = "set"
  json = templatefile("${path.module}/terraform-observe-linuxhost/boards/LinuxHostSummaryMetrics.json", {
  dataset_telegraf_systemMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_system[0].system_metrics.oid)[0][0] # extract id from oid  
  dataset_server_host = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0] # extract id from oid
  dataset_telegraf_memMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_mem[0].mem_metrics.oid)[0][0] # extract id from oid
  dataset_telegraf_processesMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_processes[0].processes_metrics.oid)[0][0] # extract id from oid
  dataset_telegraf_cPUMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_cpu[0].cpu_metrics.oid)[0][0]
  dataset_telegraf_netMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_net[0].net_metrics.oid)[0][0] # extract id from oid
  dataset_telegraf_diskMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_disk[0].disk_metrics.oid)[0][0] # extract id from oid

  })
}
resource "observe_board" "single_host_board_metrics" {
  count           = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.host.oid
  name    = "Linux Single Host Summary - BetaBoard with Metrics"
  type    = "singleton"
  json = templatefile("${path.module}/terraform-observe-linuxhost/boards/LinuxSingleHostSummaryMetrics.json", {
  dataset_telegraf_systemMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_system[0].system_metrics.oid)[0][0] # extract id from oid  
  dataset_server_host = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0] # extract id from oid
  dataset_telegraf_memMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_mem[0].mem_metrics.oid)[0][0] # extract id from oid
  dataset_telegraf_processesMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_processes[0].processes_metrics.oid)[0][0] # extract id from oid
  dataset_telegraf_cPUMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_cpu[0].cpu_metrics.oid)[0][0]
  dataset_telegraf_netMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_net[0].net_metrics.oid)[0][0] # extract id from oid
  dataset_telegraf_diskMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_disk[0].disk_metrics.oid)[0][0] # extract id from oid

  })
}
resource "observe_board" "host_interface" {
  count           = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.interface.oid
  name    = "Linux Interface Summary - BetaBoard with Metrics"
  type    = "set"
  json = templatefile("${path.module}/terraform-observe-linuxhost/boards/InterfaceOverview.json", {
  dataset_server_host = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0] # extract id from oid
  dataset_telegraf_netMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_net[0].net_metrics.oid)[0][0] # extract id from oid
  dataset_server_interface = regexall(":([^/:]*)(/|$)", module.osquery.interface.oid)[0][0] # extract id from oid
  })
}

resource "observe_board" "host_volume" {
  count           = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.volume.oid
  name    = "Linux Volume Summary - BetaBoard with Metrics"
  type    = "set"
  json = templatefile("${path.module}/terraform-observe-linuxhost/boards/VolumeOverview.json", {
  dataset_server_host = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0] # extract id from oid
  dataset_telegraf_diskMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_disk[0].disk_metrics.oid)[0][0] # extract id from oid
  dataset_server_volume = regexall(":([^/:]*)(/|$)", module.osquery.volume.oid)[0][0] # extract id from oid
  })
}