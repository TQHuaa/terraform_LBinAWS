#!/bin/bash
sudo apt update -y
sudo apt install awscli -y
sudo apt-get install keepalived haproxy -y
#aws configure set region ap-east-1
#aws s3 cp s3://huatq/index.html /var/www/html/index.html
echo ip -4 a >> /var/www/html/index.html
#systemctl start apache2 

echo 'global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    maxconn                 8000
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    retries                 3
    timeout http-request    20s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s

listen stats
    bind *:80 interface ens5
    mode http
    stats enable
    stats uri /stats
    stats realm HAProxy\ Statistics
    stats admin if TRUE

listen web-backend
    bind *:80
    balance  roundrobin
    cookie SERVERID insert indirect nocache
    mode  http
    option  httpchk
    option  httpclose
    option  httplog
    option  forwardfor
    server node1 10.0.1.86:80 check cookie node1 inter 5s fastinter 2s rise 3 fall 3
    server node2 10.0.1.87:80 check cookie node2 inter 5s fastinter 2s rise 3 fall 3' > /etc/haproxy/haproxy.cfg

touch master.sh
cp master.sh /etc/keepalived/

echo '
vrrp_instance VI_1 { 
    debug 2 
    interface ens5 # interface to monitor 
    state MASTER 
    virtual_router_id 51 # Assign one ID for this route 
    priority 101 # 101 on master, 100 on backup 
    unicast_src_ip 10.0.1.101 # My IP 
    unicast_peer {
        10.0.1.102 # peer IP 
    } 
    notify_master /etc/keepalived/master.sh 
}
' > /etc/keepalived/keepalived.conf

service haproxy start

service keepalived start  