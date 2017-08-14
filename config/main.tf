/*
Mesanine uses Terraform to construct Ignition 
configuration files that get loaded into the OS
from user-data. Be aware that some aspects of
Ignition (like systemd units) are not supported!
*/

data "ignition_file" "mesos_master_envs_json" {
  filesystem = "root"
  path       = "${var.config_path}/mesos-master/envs.json"

  content {
    content = "${jsonencode(var.mesos_master_envs)}"
  }
}

data "ignition_file" "mesos_agent_envs_json" {
  filesystem = "root"
  path       = "${var.config_path}/mesos-agent/envs.json"

  content {
    content = "${jsonencode(var.mesos_agent_envs)}"
  }
}

data "ignition_file" "zetcd_envs_json" {
  filesystem = "root"
  path       = "${var.config_path}/zetcd/envs.json"

  content {
    content = "${jsonencode(var.zetcd_envs)}"
  }
}

data "ignition_file" "authorized_keys" {
  filesystem = "root"
  path       = "${var.config_path}/sshd/authorized_keys"
  mode       = 0600

  content {
    content = "${file("./config/files/authorized_keys")}"
  }
}

data "ignition_file" "docker_lib" {
  filesystem = "root"
  path       = "/var/lib/docker/_placeholder"
  mode       = 0600

  content {
    content = "1"
  }
}

data "ignition_config" "mesanine-master" {
  files = [
    "${data.ignition_file.mesos_master_envs_json.id}",
    "${data.ignition_file.zetcd_envs_json.id}",
    "${data.ignition_file.authorized_keys.id}",
    "${data.ignition_file.mesos_agent_envs_json.id}",
    "${data.ignition_file.authorized_keys.id}",
    "${data.ignition_file.docker_lib.id}",
  ]
}

data "ignition_config" "mesanine-agent" {
  files = [
    "${data.ignition_file.mesos_agent_envs_json.id}",
    "${data.ignition_file.authorized_keys.id}",
    "${data.ignition_file.docker_lib.id}",
  ]
}

output ignition-cfg-master {
  value = "${data.ignition_config.mesanine-master.rendered}"
}

output ignition-cfg-agent {
  value = "${data.ignition_config.mesanine-agent.rendered}"
}
