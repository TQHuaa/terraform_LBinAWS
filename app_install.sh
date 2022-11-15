#!/bin/bash
sudo apt update -y
sudo apt install awscli -y
sudo apt-get install apache2 -y
#aws configure set region ap-east-1
#aws s3 cp s3://huatq/index.html /var/www/html/index.html
ip -4 a > /var/www/html/index.html
systemctl start apache2