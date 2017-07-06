#!/bin/sh
set -xe

CONFIG_PATH="/var/config/mesos/env"
DEFAULT_CONFIG_PATH="/env_defaults"

if [[ -f "$CONFIG_PATH" ]] ; then {
  source "$CONFIG_PATH"
} else {
  source "$DEFAULT_CONFIG_PATH"
}
fi

# Libprocess MUST be able to resolve our hostname
# Some environments such as runc don't automatically
# specify this like Docker does. It can also be used
# with the --discover-ip flag
cat > /sbin/discover-ip <<-__EOF__ 
#!/bin/sh
ip addr |grep 'state UP' -A2 |tail -n1 | awk '{print \$2}' | sed 's/\/.*//'
__EOF__

chmod +x /sbin/discover-ip

echo "$(discover-ip)      $(hostname)" >> /etc/hosts

exec "$@"
