#!/bin/bash
# Basic entrypoint for ROS / Colcon Docker containers

# Source ROS 2
source /opt/ros/${ROS_DISTRO}/setup.bash
echo "Sourced ROS 2 ${ROS_DISTRO}"

# Source the base workspace, if built
if [ -f ${UNDERLAY_WS}/install/setup.bash ]
then
  source ${UNDERLAY_WS}/install/setup.bash
  #export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/models
  echo "Sourced Bot Mini base workspace"
fi

# Source the overlay workspace, if built
if [ -f /overlay_ws/install/setup.bash ]
then
  source /overlay_ws/install/setup.bash
  #export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$(ros2 pkg prefix tb3_worlds)/share/tb3_worlds/models
  echo "Sourced Bot Mini overlay workspace"
fi

# Start Robot ROS2 Nodes
ros2 launch bot_mini_bringup robot_controller.launch.py priority:=80 cpu-affinity:=4 lock-memory-size:=100 config-child-threads:=True &
ros2 launch bot_mini_bringup robot_twist_mux.launch.py &
ros2 launch bot_mini_bringup robot_joy_teleop.launch.py

wait