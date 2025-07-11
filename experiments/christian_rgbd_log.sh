#!/usr/bin/env bash

ros2 bag record \
    --topics \
        /camera/depth/camera_info \
        /camera/depth/image_raw/compressed \
        /camera/color/camera_info \
        /camera/color/image_raw/compressed \
        /camera/imu \
        /tf \
        /tf_static \
        /odom \
        /cmd_vel_out \
        /scan \
        /speed_fb \
        /map \
    --output $1

ros2 bag info $1
