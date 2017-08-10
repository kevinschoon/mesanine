variable "config_path" {
  default = "/var/mesanine"
}

variable "mesos_master_envs" {
  default = {
    "MESOS_ZK"            = "zk://localhost:2181/mesos"
    "MESOS_LOGGING_LEVEL" = "WARNING"
    "MESOS_WORK_DIR"      = "/var/run/mesos"
    "MESOS_QUORUM"        = "1"
  }
}

variable "mesos_agent_envs" {
  default = {
    "MESOS_MASTER"          = "zk://localhost:2181/mesos"
    "MESOS_CONTAINERIZERS"  = "mesos"
    "MESOS_LAUNCHER"        = "posix"
    "MESOS_LOGGING_LEVEL"   = "WARNING"
    "MESOS_ISOLATION"       = "posix/cpu,posix/mem"
    "MESOS_IMAGE_PROVIDERS" = "APPC"
  }
}

variable "zetcd_envs" {
  default = {
    "ETCD_ENDPOINTS" = "127.0.0.1:2379"
  }
}
