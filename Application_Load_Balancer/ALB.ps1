#connect AWS
aws configure
AWS Access Key ID
AWS Secret Access Key
Default region name (e.g., us-east-1)
Default output format (e.g., json)


#aws vpc detail
$VPC = (aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)

#create key manually
aws ec2 create-key-pair --key-name key1 --query "KeyMaterial" --output text > MyKeyPair.pem

#save ip
$IPADD = (Invoke-RestMethod -Uri "https://checkip.amazonaws.com").Trim()


#create security group
$SGID = (aws ec2 create-security-group --group-name MySecGrp --description "my lab sec group" --query 'GroupId' --output text)

#open ports for ec2 interface
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol tcp --port  22 --cidr $IPADD/32
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol tcp --port  80 --cidr 0.0.0.0/0

#create subnet
$AZ1SUB = (aws ec2 create-subnet --vpc-id $VPC --availability-zone-id use1-az1 --cidr-block 172.31.128.0/20 --query 'Subnet.SubnetId' --output text)
$AZ2SUB = (aws ec2 create-subnet --vpc-id $VPC --availability-zone-id use1-az2 --cidr-block 172.31.192.0/20 --query 'Subnet.SubnetId' --output text)

#create ec2 instance - 2 for VID and 2 for WEB
$VIDSERVER1 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ1SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://user-data-vid1.txt --query 'Instances[0].InstanceId' --output text)
$VIDSERVER2 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ2SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://user-data-vid2.txt --query 'Instances[0].InstanceId' --output text)
$WEBSERVER1 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ1SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://user-data-web1.txt --query 'Instances[0].InstanceId' --output text)
$WEBSERVER2 = (aws ec2 run-instances --image-id ami-0341d95f75f311023 --instance-type t2.micro --count 1 --subnet-id $AZ2SUB --key-name key1 --security-group-ids $SGID --associate-public-ip-address --user-data file://user-data-web2.txt --query 'Instances[0].InstanceId' --output text)

#create tags for ec2 instances
aws ec2 create-tags --resources $VIDSERVER1 --tags Key="Name",Value="Video 1"
aws ec2 create-tags --resources $VIDSERVER2 --tags Key="Name",Value="Video 2"
aws ec2 create-tags --resources $WEBSERVER1 --tags Key="Name",Value="Web 1"
aws ec2 create-tags --resources $WEBSERVER2 --tags Key="Name",Value="Web 2"
#start-process http://3.82.113.20
#Start-Process http://18.207.99.6
#Start-Process http://44.203.201.9/vid
#Start-Process http://44.193.203.16/vid

#create application load balancer
$ALBARN = (aws elbv2 create-load-balancer --name MyALB --subnets $AZ1SUB $AZ2SUB --security-groups $SGID --query 'LoadBalancers[0].LoadBalancerArn' --output text)
$ALBDNS = (aws elbv2 describe-load-balancers --load-balancer-arns $ALBARN --query 'LoadBalancers[0].DNSName' --output text)

#create target groups
$VIDTGARN = (aws elbv2 create-target-group --name VideoTargets --protocol HTTP --port 80 --vpc-id $VPC --query 'TargetGroups[0].TargetGroupArn' --output text)
$WEBTGARN = (aws elbv2 create-target-group --name WebTargets --protocol HTTP --port 80 --vpc-id $VPC --query 'TargetGroups[0].TargetGroupArn' --output text)

#register target groups
aws elbv2 register-targets --target-group-arn $VIDTGARN --targets Id=$VIDSERVER1 Id=$VIDSERVER2
aws elbv2 register-targets --target-group-arn $WEBTGARN --targets Id=$WEBSERVER1 Id=$WEBSERVER2

#create listener for target group
$LISTARN = (aws elbv2 create-listener --load-balancer-arn $ALBARN --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$WEBTGARN --query 'Listeners[0].ListenerArn' --output text)

#check health of target group
aws elbv2 describe-target-health --target-group-arn $VIDTGARN
aws elbv2 describe-target-health --target-group-arn $WEBTGARN

#path based routing rule
aws elbv2 create-rule --listener-arn $LISTARN --priority 5 --conditions file://condition.json --action Type=forward,TargetGroupArn=$VIDTGARN

aws elbv2 modify-target-group `
  --target-group-arn $VIDTGARN `
  --health-check-path /vid/

aws elbv2 describe-target-groups --target-group-arns $VIDTGARN



#copy ARNs of listener rule
$VIDRULEARN = (aws elbv2 describe-rules --listener-arn $LISTARN --query 'Rules[0].RuleArn' --output text)
$WEBRULEARN = (aws elbv2 describe-rules --listener-arn $LISTARN --query 'Rules[0].RuleArn' --output text)

#browse website
Start-Process http://$ALBDNS

#DELETE EVERYTHING
aws elbv2 delete-rule --rule-arn $VIDRULEARN; start-sleep -Seconds 5
aws elbv2 delete-rule --rule-arn $WEBRULEARN; start-sleep -Seconds 5
aws elbv2 delete-listener --listener-arn $LISTARN; start-sleep -Seconds 5
aws elbv2 delete-target-group --target-group-arn $VIDTGARN; start-sleep -Seconds 5
aws elbv2 delete-target-group --target-group-arn $WEBTGARN; start-sleep -Seconds 5
aws elbv2 delete-load-balancer --load-balancer-arn $ALBARN; start-sleep -Seconds 5
aws ec2 terminate-instances --instance-ids $VIDSERVER1 $VIDSERVER2 $WEBSERVER1 $WEBSERVER2; start-sleep -Seconds 20
aws ec2 delete-subnet --subnet-id $AZ1SUB; start-sleep -Seconds 2
aws ec2 delete-subnet --subnet-id $AZ2SUB; start-sleep -Seconds 2
aws ec2 delete-security-group --group-id $SGID; start-sleep -Seconds 5







