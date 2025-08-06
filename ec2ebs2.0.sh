#!/bin/bash
STANCE_TYPE="t3.micro"
AVAILABITY_ZONE="sa-east-1"
create_EC2 () {

AMI="ami-020cba7c55df1f615"

Firewall="launch-wizard-1"
 
KEY_NAME="girl"

Volumesize=8

INSTANCE_ID=$(aws ec2 run-instances \
--image-id "$AMI" \
--instance-type "$STANCE_TYPE" \
--placement AvailabilityZone="$AVAILABITY_ZONE" \
--key-name "$KEY_NAME" \
--security-groups "$Firewall" \
--block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":$Volumesize}}]" \
--query "Instances[0].InstanceId" \
--output text)
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
}

create_EBS () {

SIZE=8
IOPS=3000
Attached="/dev/sdf"
VOLUME_TYPE="io1"
volume_ID=$(aws ec2 create-volume \
--size "$SIZE" \
--availability-zone "$AVAILABITY_ZONE" \
--iops "$IOPS" \
--volume-type "$VOLUME_TYPE" \
--query "VolumeId" \
--output text)
aws ec2 wait volume-available --volume-ids "$volume_ID"
aws ec2 attach-volume \
--volume-id "$volume_ID" \
--instance-id "$INSTANCE_ID" \
--device "$Attached"
aws ec2 wait volume-in-use --volume-ids "$volume_ID"
sleep 10

}

mount_ebs () {
DEVICE_NAME="/dev/sdf"
MOUNT_POINT="/mnt/ebs"
sudo mkfs -t ext4 $DEVICE_NAME
sudo mkdir -p $MOUNT_POINT
sudo mount $DEVICE_NAME $MOUNT_POINT

echo "$DEVICE_NAME $MOUNT_POINT ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
}

create_EC2
create_EBS
mount_ebs
