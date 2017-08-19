/*
Mesanine uses Terraform to construct Ignition 
configuration files that get loaded into the OS
from user-data. Be aware that some aspects of
Ignition (like systemd units) are not supported!
*/

data "ignition_file" "mesos_master_envs_json" {
  filesystem = "var"
  path       = "/mesanine/mesos-master/envs.json"

  content {
    content = "${jsonencode(var.mesos_master_envs)}"
  }
}

data "ignition_file" "mesos_agent_envs_json" {
  filesystem = "var"
  path       = "/mesanine/mesos-agent/envs.json"

  content {
    content = "${jsonencode(var.mesos_agent_envs)}"
  }
}

data "ignition_file" "marathon_envs_json" {
  filesystem = "var"
  path       = "/mesanine/marathon/envs.json"

  content {
    content = "${jsonencode(var.marathon_envs)}"
  }
}

data "ignition_file" "zetcd_envs_json" {
  filesystem = "var"
  path       = "/mesanine/zetcd/envs.json"

  content {
    content = "${jsonencode(var.zetcd_envs)}"
  }
}

data "ignition_file" "authorized_keys" {
  filesystem = "var"
  path       = "/mesanine/sshd/authorized_keys"
  mode       = 0600

  content {
    content = "${file("./config/files/authorized_keys")}"
  }
}

data "ignition_file" "docker_lib" {
  filesystem = "var"
  path       = "/lib/docker/_placeholder"
  mode       = 0600

  content {
    content = "1"
  }
}

data "ignition_file" "mesos_run" {
  filesystem = "var"
  path       = "/run/mesos/_placeholder"
  mode       = 0600

  content {
    content = "1"
  }
}

data "ignition_disk" "var" {
  device     = "/dev/sda"
  wipe_table = true
}

data "ignition_filesystem" "var" {
  name = "var"

  mount {
    device  = "/dev/sda"
    format  = "ext4"
    create  = true
    force   = true
    options = ["-L", "ROOT"]
  }
}

data "ignition_config" "mesanine-master" {
  files = [
    "${data.ignition_file.mesos_master_envs_json.id}",
    "${data.ignition_file.marathon_envs_json.id}",
    "${data.ignition_file.zetcd_envs_json.id}",
    "${data.ignition_file.authorized_keys.id}",
    "${data.ignition_file.mesos_agent_envs_json.id}",
    "${data.ignition_file.authorized_keys.id}",
    "${data.ignition_file.docker_lib.id}",
    "${data.ignition_file.mesos_run.id}",
  ]

  disks = [
    "${data.ignition_disk.var.id}",
  ]

  filesystems = [
    "${data.ignition_filesystem.var.id}",
  ]
}

data "ignition_config" "mesanine-agent" {
  files = [
    "${data.ignition_file.mesos_agent_envs_json.id}",
    "${data.ignition_file.authorized_keys.id}",
    "${data.ignition_file.docker_lib.id}",
    "${data.ignition_file.mesos_run.id}",
  ]

  disks = [
    "${data.ignition_disk.var.id}",
  ]

  filesystems = [
    "${data.ignition_filesystem.var.id}",
  ]
}

output ignition-cfg-master {
  value = "${data.ignition_config.mesanine-master.rendered}"
}

output ignition-cfg-agent {
  value = "${data.ignition_config.mesanine-agent.rendered}"
}
