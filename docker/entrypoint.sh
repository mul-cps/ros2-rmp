#!/bin/bash
# Basic entrypoint for ROS / Colcon Docker containers

UNDERLAY_WS=/rmp_ws

# Source ROS 2
source /opt/ros/${ROS_DISTRO}/setup.bash
echo "Sourced ROS 2 ${ROS_DISTRO}"

# Source the base workspace, if built
if [ -f ${UNDERLAY_WS}/install/setup.bash ]
then
  source ${UNDERLAY_WS}/install/setup.bash
  #export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/models
  echo "Sourced CPS RMP 220 base workspace"
fi

# Source the overlay workspace, if built
if [ -f /overlay_ws/install/setup.bash ]
then
  source /overlay_ws/install/setup.bash
  #export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$(ros2 pkg prefix tb3_worlds)/share/tb3_worlds/models
  echo "Sourced CPS RMP 220 Overlay workspace"
fi

# Execute the command passed into this entrypoint
exec "$@"