
#connet aws
aws configure


#create key manually
aws ec2 create-key-pair --key-name $keyName --query "KeyMaterial" --output text > key1.pem


#aws vpc detail
$VPC = (aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)

#save ip
$IPADD = (Invoke-RestMethod -Uri "https://checkip.amazonaws.com").Trim()


#create security group
$SGID = (aws ec2 create-security-group --group-name MySecGrp --description "my lab sec group" --query 'GroupId' --output text)

#open ports for ec2 interface
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol tcp --port  22 --cidr $IPADD/32
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol udp --port  6380 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol tcp --port  6381 --cidr 0.0.0.0/0

#create subnet
$AZ1SUB = (aws ec2 create-subnet --vpc-id $VPC --availability-zone-id use1-az1 --cidr-block 172.31.128.0/20 --query 'Subnet.SubnetId' --output text)
$AZ2SUB = (aws ec2 create-subnet --vpc-id $VPC --availability-zone-id use1-az2 --cidr-block 172.31.192.0/20 --query 'Subnet.SubnetId' --output text)


#create ec2 instance - 2 for VID and 2 for WEB
$TCPSERVER1 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ1SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://tcp-user-data.txt --query 'Instances[0].InstanceId' --output text)
$TCPSERVER2 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ2SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://tcp-user-data.txt --query 'Instances[0].InstanceId' --output text)
$UDPSERVER1 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ1SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://udp-user-data.txt --query 'Instances[0].InstanceId' --output text)
$UDPSERVER2 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ2SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://udp-user-data.txt --query 'Instances[0].InstanceId' --output text)

#create tags for ec2 instances
aws ec2 create-tags --resources $TCPSERVER1 --tags Key="Name",Value="TCPSERVER1"
aws ec2 create-tags --resources $TCPSERVER2 --tags Key="Name",Value="TCPSERVER2"
aws ec2 create-tags --resources $UDPSERVER1 --tags Key="Name",Value="UDPSERVER1"
aws ec2 create-tags --resources $UDPSERVER2 --tags Key="Name",Value="UDPSERVER2"

#test on local server by doing ssh
# for tcp: sudo ss -tulnp | grep 6381
# for udp: ps aux | grep udp_server.py
#          sudo ss -u -l -n | grep 6380

#create network load balancer
$NLBARN = (aws elbv2 create-load-balancer --name MyNLB --type network --subnets $AZ1SUB $AZ2SUB --security-groups $SGID --query 'LoadBalancers[0].LoadBalancerArn' --output text)
$NLBDNS = (aws elbv2 describe-load-balancers --load-balancer-arns $NLBARN --query 'LoadBalancers[0].DNSName' --output text)

#create target groups
$TCPTGARN = (aws elbv2 create-target-group --name TCPTargets --protocol TCP --port 6381 --vpc-id $VPC --query 'TargetGroups[0].TargetGroupArn' --output text)
$UDPTGARN = (aws elbv2 create-target-group --name UDPTargets --protocol UDP --port 6380 --vpc-id $VPC --query 'TargetGroups[0].TargetGroupArn' --output text)

#register target groups
aws elbv2 register-targets --target-group-arn $TCPTGARN --targets Id=$TCPSERVER1 Id=$TCPSERVER2
aws elbv2 register-targets --target-group-arn $UDPTGARN --targets Id=$UDPSERVER1 Id=$UDPSERVER2

#create listener for target group
$TCPLISTARN = (aws elbv2 create-listener --load-balancer-arn $NLBARN --protocol TCP --port 6381 --default-actions Type=forward,TargetGroupArn=$TCPTGARN --query 'Listeners[0].ListenerArn' --output text)
$UDPLISTARN = (aws elbv2 create-listener --load-balancer-arn $NLBARN --protocol UDP --port 6380 --default-actions Type=forward,TargetGroupArn=$UDPTGARN --query 'Listeners[0].ListenerArn' --output text)

#copy ARNs of listener rule
$TCPRULEARN = (aws elbv2 describe-rules --listener-arn $TCPLISTARN --query 'Rules[0].RuleArn' --output text)
$UDPRULEARN = (aws elbv2 describe-rules --listener-arn $UDPLISTARN --query 'Rules[0].RuleArn' --output text)



#TEST TCP
python3 -c "
import socket
nlbdns = '$NLBDNS'.strip()   # remove any leading/trailing whitespace
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(2)
s.connect((nlbdns, 6381))
s.sendall(b'ping')
data = s.recv(1024)
print('Reply:', data.decode())
s.close()
"


Test-NetConnection -ComputerName $NLBDNS -Port 6381


# TEST UDP
python3 -c "
import socket
nlbdns = '$NLBDNS'.strip()   # remove any leading/trailing whitespace
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(2)
s.sendto(b'ping', (nlbdns, 6380))
data, addr = s.recvfrom(1024)
print('Reply:', data.decode())
s.close()
"



#DELETE EVERYTHING
aws elbv2 delete-listener --listener-arn $TCPLISTARN; start-sleep -Seconds 5
aws elbv2 delete-listener --listener-arn $UDPLISTARN; start-sleep -Seconds 5
aws elbv2 delete-target-group --target-group-arn $TCPTGARN; start-sleep -Seconds 5
aws elbv2 delete-target-group --target-group-arn $UDPTGARN; start-sleep -Seconds 5
aws elbv2 delete-load-balancer --load-balancer-arn $NLBARN; start-sleep -Seconds 5
aws ec2 terminate-instances --instance-ids $TCPSERVER1 $TCPSERVER2 $UDPSERVER1 $UDPSERVER2; start-sleep -Seconds 20
aws ec2 delete-security-group --group-id $SGID; start-sleep -Seconds 5
aws ec2 delete-subnet --subnet-id $AZ1SUB; start-sleep -Seconds 2
aws ec2 delete-subnet --subnet-id $AZ2SUB; start-sleep -Seconds 2
aws elbv2 delete-rule --rule-arn $TCPRULEARN; start-sleep -Seconds 5
aws elbv2 delete-rule --rule-arn $UDPRULEARN; start-sleep -Seconds 5
