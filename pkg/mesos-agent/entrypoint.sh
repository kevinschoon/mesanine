#!/bin/bash

exec /usr/local/sbin/mesos-agent --ip_discovery_command=/sbin/discover-ip --work_dir=/var/run/mesos
