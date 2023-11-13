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
  vcs pull ${UNDERLAY_WS}/src
  echo "Sourced CPS RMP 220 base workspace"
fi

# Source the overlay workspace, if built
if [ -f /overlay_ws/install/setup.bash ]
then
  source /overlay_ws/install/setup.bash
  vcs pull /overlay_ws/src
  echo "Sourced CPS RMP 220 Overlay workspace"
fi

# Source the bridge workspace, if built
if [ -f ~/ros2_humble/install/setup.bash ]
then
  source ~/ros2_humbleinstall/setup.bash
  #export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/models
  echo "Sourced CPS RMP 220 base workspace"
fi

# Implement updating all repositories at launch
if [ -f ${UNDERLAY_WS}/]
then
  cd ${UNDERLAY_WS}
  vcs pull src
  echo "Updated base workspace"
fi

if [ -f /overlay_ws/]
then
  cd /overlay_ws
  vcs pull src
  echo "Updated overlay workspace"
fi

# configure container networking to use zerotier interface as standard gateway
# this might be for later
# if [ -f /zerotier-one/zerotier-cli ]
# then
#   /zerotier-one/zerotier-cli join 8056c2e21c000001
#   echo "Joined zerotier network"
# fi
# set standard gateway to zerotier interface
ip route del default
ip route add default via $(ip addr show zt0 | grep -Po 'inet \K[\d.]+')
echo "Set zerotier interface as standard gateway"
# this should now route the ros2 traffic through zerotier?


# Execute the command passed into this entrypoint
exec "$@"