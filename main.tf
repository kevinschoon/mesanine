module "config" {
  source = "./config"
}

resource "local_file" "master-ign" {
  content  = "${module.config.ignition-cfg-master}"
  filename = "${path.module}/target/master.ign"
}

resource "local_file" "agent-ign" {
  content  = "${module.config.ignition-cfg-agent}"
  filename = "${path.module}/target/agent.ign"
}
