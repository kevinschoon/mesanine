FROM mesanine/mesos

COPY discover-ip /sbin/

LABEL org.mobyproject.config='{"pid": "host", "net": "host", "binds": ["/var/run/mesos:/var/run/mesos"], "capabilities": ["all"]}'

CMD ["/usr/local/sbin/mesos-agent", "--ip_discovery_command=/sbin/discover-ip", "--work_dir=/var/run/mesos"]
