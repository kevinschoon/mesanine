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
    "MESOS_CONTAINERIZERS"  = "mesos,docker"
    "MESOS_LAUNCHER"        = "linux"
    "MESOS_LOGGING_LEVEL"   = "WARNING"
    "MESOS_ISOLATION"       = "cgroups/cpu,cgroups/mem,cgroups/pids,namespaces/pid,filesystem/shared,filesystem/linux,volume/sandbox_path,docker/runtime"
    "MESOS_IMAGE_PROVIDERS" = "APPC,DOCKER"
  }
}

variable "zetcd_envs" {
  default = {
    "ETCD_ENDPOINTS" = "127.0.0.1:2379"
  }
}
