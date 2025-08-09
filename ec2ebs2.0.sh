#!/bin/bash

INSTANCE_TYPE="t3.micro"
AVAILABILITY_ZONE="sa-east-1a"
AMI="ami-020cba7c55df1f615"
FIREWALL="launch-wizard-1"
KEY_NAME="girl"
VOLUME_SIZE=20

export INSTANCE_ID=""

create_EC2() {
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI" \
        --instance-type "$INSTANCE_TYPE" \
        --placement AvailabilityZone="$AVAILABILITY_ZONE" \
        --key-name "$KEY_NAME" \
        --security-groups "$FIREWALL" \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":$VOLUME_SIZE}}]" \
        --query "Instances[0].InstanceId" \
        --output text)
    export INSTANCE_ID
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
}

create_EBS() {
    SIZE=8
    IOPS=3000
    ATTACHED="/dev/sdf"
    VOLUME_TYPE="io1"
    VOLUME_ID=$(aws ec2 create-volume \
        --size "$SIZE" \
        --availability-zone "$AVAILABILITY_ZONE" \
        --iops "$IOPS" \
        --volume-type "$VOLUME_TYPE" \
        --query "VolumeId" \
        --output text)
    aws ec2 wait volume-available --volume-ids "$VOLUME_ID"
    aws ec2 attach-volume \
        --volume-id "$ VOLUME_ID" \
        --instance-id "$INSTANCE_ID" \
        --device "$ATTACHED"
    aws ec2 wait volume-in-use --volume-ids "$VOLUME_ID"
    sleep 10
}

mount_ebs() {
    DEVICE_NAME="/dev/sdf"
    MOUNT_POINT="/mnt/ebs"
    sudo mkfs -t ext4 $DEVICE_NAME
    sudo mkdir -p $MOUNT_POINT
    sudo mount $DEVICE_NAME $MOUNT_POINT

    echo "$DEVICE_NAME $MOUNT_POINT ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
    sudo yum update -y
}

create_EC2
create_EBS
mount_ebs
