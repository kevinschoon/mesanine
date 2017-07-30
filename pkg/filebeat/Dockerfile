FROM quay.io/vektorcloud/filebeat

COPY filebeat.yml /opt/filebeat/filebeat.yml

ENV ES_HOSTS 10.0.2.100:9200

LABEL org.mobyproject.config='{"pid": "host", "binds": ["/var/log:/var/log"], "capabilities": []}'

CMD ["/opt/filebeat/filebeat", "-e"]
