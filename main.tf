module "config" {
  source = "./config"
}

resource "local_file" "ign" {
  content  = "${module.config.ignition-cfg}"
  filename = "${path.module}/target/mesanine.ign"
}
