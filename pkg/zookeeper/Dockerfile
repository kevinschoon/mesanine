FROM quay.io/vektorcloud/zookeeper:latest

COPY entrypoint.sh /
COPY zoo.cfg /opt/zookeeper/conf/

RUN echo -n "1" > /opt/zookeeper/data/myid
