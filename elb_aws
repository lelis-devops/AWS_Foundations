#!/bin/bash

launch_template="DevTemplate"
asg_name="DevASG"

create_launch_template() {
  version_description="v1"

  aws ec2 create-launch-template \
    --launch-template-name "$launch_template" \
    --version-description "$version_description" \
    --launch-template-data '{
      "ImageId": "ami-0c55b159cbfafe1f0",
      "InstanceType": "t3.micro",
      "KeyName": "ketchup",
      "SecurityGroupIds": ["sg-0123456789abcdef0"],
      "UserData": "'"$(echo -n '#!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "<h1>Welcome, Sir! </h1>" > /var/www/html/index.html' | base64)"'"
    }'
}

create_target_group() {
  name_tg="nebula"
  vpc_id="vpc-0b17fdb1a62eec6b2"

  tg_arn=$(aws elbv2 create-target-group \
    --name "$name_tg" \
    --protocol HTTP \
    --port 80 \
    --vpc-id "$vpc_id" \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
}

create_load_balancer() {
  name_lb="newnebu"
  subnets_lb="subnet-05682cb0af67aa733 subnet-0b5662c9abe10f0d3 subnet-0796e9a01082d7405"
  security_group="sg-02e1cb308c27a897a"

  lb_arn=$(aws elbv2 create-load-balancer \
    --name "$name_lb" \
    --subnets $subnets_lb \
    --security-groups "$security_group" \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)
}

create_auto_scaling_group() {

  aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name "$asg_name" \
    --launch-template LaunchTemplateName="$launch_template",Version=1 \
    --min-size 1 \
    --max-size 3 \
    --desired-capacity 1 \
    --vpc-zone-identifier "$subnets_lb" \
    --target-group-arns "$tg_arn"
}

create_scaling_policy() {
  policy_arn=$(aws autoscaling put-scaling-policy \
    --policy-name ScaleOutPolicy \
    --auto-scaling-group-name "$asg_name" \
    --scaling-adjustment 1 \
    --adjustment-type ChangeInCapacity \
    --cooldown 300 \
    --query 'PolicyARN' \
    --output text)
}

create_cloud_watch() {
  aws cloudwatch put-metric-alarm \
    --alarm-name "HighCPUAlarm" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 60 \
    --threshold 70 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=AutoScalingGroupName,Value="$asg_name" \
    --evaluation-periods 2 \
    --alarm-actions "$policy_arn"
}


create_launch_template
create_target_group
create_load_balancer
create_auto_scaling_group
create_scaling_policy
create_cloud_watch
