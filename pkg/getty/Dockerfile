FROM linuxkit/getty:5ab31289889d61a5d2ecbeea8e36ce74ac54737c

COPY motd /etc/

LABEL org.mobyproject.config='{"pid": "host", "net":"host", "binds": ["/run:/run", "/tmp:/tmp", "/:/hostroot", "/var:/var","/dev:/dev","/sys:/sys"], "capabilities": ["all"]}'
