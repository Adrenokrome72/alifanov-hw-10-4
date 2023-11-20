#!/bin/bash/

ansible kibana -m shell -a "systemctl status kibana"
ansible web -m shell -a "systemctl status nginx nginx-log-exporter filebeat node-exporter"
ansible elastic -m shell -a "systemctl status elasticsearch"
ansible prometheus -m shell -a "systemctl status prometheus"
ansible grafana -m shell -a "systemctl status grafana"

curl -v 158.160.133.68:80

yc compute instance list
yc vpc network list
yc vpc subnet list
yc vpc security-group list
yc compute snapshot-schedule list
yc compute snapshot list
