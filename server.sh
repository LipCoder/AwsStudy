#!/bin/bash -e
# You need to install the AWS Command Line Interface from http://aws.amazon.com/cli/

# Get Amazon Machine Image ID
AMIID=$(aws ec2 describe-images --filters "Name=description, Values=Amazon Linux AMI 2015.03.? x86_64 HVM GP2" --query "Images[0].ImageId" --output text)
# Get Virtual Private Cloud ID
# Default VPC
VPCID=$(aws ec2 describe-vpcs --filter "Name=isDefault, Values=true" --query "Vpcs[0].VpcId" --output text)
# Get Subnet ID
SUBNETID=$(aws ec2 describe-subnets --filters "Name=vpc-id, Values=$VPCID" --query "Subnets[0].SubnetId" --output text)
# Create Security Group
SGID=$(aws ec2 create-security-group --group-name mysecuritygroup --description "My security group" --vpc-id $VPCID --output text)
# 들어오는 SSH 연결 허용
aws ec2 authorize-security-group-ingress --group-id $SGID --protocol tcp --port 22 --cidr 0.0.0.0/0
# Run Instance
INSTANCEID=$(aws ec2 run-instances --image-id $AMIID --key-name mykey --instance-type t2.micro --security-group-ids $SGID --subnet-id $SUBNETID --query "Instances[0].InstanceId" --output text)
echo "waiting for $INSTANCEID ..."
# 시작할때까지 대기
aws ec2 wait instance-running --instance-ids $INSTANCEID

# Get EC2 public IP
# 서버의 공용이름을 얻는다
PUBLICNAME=$(aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservations[0].Instances[0].PublicDnsName" --output text)

# Can connect to ec2 by SSH
echo "$INSTANCEID is accepting SSH connections under $PUBLICNAME"
echo "ssh -i mykey.pem ec2-user@$PUBLICNAME"

# Terminate ec2
read -p "Press [Enter] key to terminate $INSTANCEID ..."
aws ec2 terminate-instances --instance-ids $INSTANCEID
echo "terminating $INSTANCEID ..."
# 종료할때까지 대기
aws ec2 wait instance-terminated --instance-ids $INSTANCEID

# Delete Security Group
aws ec2 delete-security-group --group-id $SGID
echo "done."
