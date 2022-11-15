#!/bin/bash 
EIP=9.8.7.6 
INSTANCE_ID=i-abcd1234 

/usr/local/bin/aws ec2 disassociate-address --public-ip $EIP 
/usr/local/bin/aws ec2 associate-address --public-ip $EIP --instance-id $INSTANCE_ID