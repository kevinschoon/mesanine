FROM mesanine/base AS base

RUN add-pkgs \
  curl \
  htop \
  file \
  jq \
  openssh-server \
  tini \
  vim 

FROM scratch
ENTRYPOINT []
WORKDIR /
COPY --from=base /base/ /
COPY etc/ /etc/
COPY usr/ /usr/
RUN mkdir -p /etc/ssh /root/.ssh && chmod 0700 /root/.ssh
CMD ["/sbin/tini", "/usr/bin/ssh.sh"]
LABEL org.mobyproject.config='{"pid": "host", "binds": ["/var/mesanine/sshd:/root/.ssh", "/etc/resolv.conf:/etc/resolv.conf", "/:/hostroot", "/usr/bin/gaffer:/usr/bin/gaffer", "/usr/bin/runc:/usr/bin/runc", "/containers:/containers", "/dev:/dev", "/sys:/sys", "/lib/modules:/lib/modules"], "mounts": [{"type": "cgroup", "options": ["rw", "nosuid", "noexec", "nodev", "relatime"]}], "capabilities": ["all"]}'
