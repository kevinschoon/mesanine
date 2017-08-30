FROM alpine:3.6

RUN apk add --no-cache \
  curl \
  htop \
  file \
  jq \
  openssh-server \
  vim 

COPY etc/ /etc/
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
RUN mkdir -p /etc/ssh /root/.ssh && chmod 0700 /root/.ssh
LABEL org.mobyproject.config='{"pid": "host", "binds": ["/var/mesanine/sshd:/root/.ssh", "/etc/resolv.conf:/etc/resolv.conf"], "mounts": [{"type": "cgroup", "options": ["rw", "nosuid", "noexec", "nodev", "relatime"]}], "capabilities": ["all"]}'
