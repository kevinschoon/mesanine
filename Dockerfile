FROM alpine:edge

ENV AMITOOLS_VERSION=1.5.7
ENV EC2_AMITOOL_HOME=/usr/local/ec2-ami-tools-$AMITOOLS_VERSION
ENV PATH=$EC2_AMITOOL_HOME/bin:$PATH

RUN apk update \
    && apk add --no-cache \
      alpine-sdk \
      bash \
      linux-headers \
      cryptsetup-dev \
      kmod-dev \
      ruby \
      syslinux \
      util-linux-dev \
      xorriso \
    && adduser -D builder \
    && addgroup builder abuild \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir -p /var/cache/distfiles \
    && chmod a+w /var/cache/distfiles \
    && mkdir /home/builder/target \ 
    && curl -s http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-$AMITOOLS_VERSION.zip -o /tmp/ec2-ami-tools-$AMITOOLS_VERSION.zip \
    && mkdir -p /usr/local/ec2 \
    && unzip /tmp/ec2-ami-tools-$AMITOOLS_VERSION.zip -d /usr/local

COPY mkinitfs /tmp/mkinitfs

# Override default mkinitfs for now
RUN cd /tmp/mkinitfs \
  && make \
  && make install

COPY entrypoint.sh /
WORKDIR /home/builder/target
CMD "/bin/sh"
ENTRYPOINT ["/entrypoint.sh"]
