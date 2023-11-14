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
# # set standard gateway to zerotier interface
# ip route del default
# ip route add default via $(ip addr show zt* | grep -Po 'inet \K[\d.]+')
# echo "Set zerotier interface as standard gateway"
# this should now route the ros2 traffic through zerotier?

# # Find the ZeroTier interface name dynamically
# zerotier_interface=$(ip addr show | awk '/^.*: zt/{print $2}' | cut -d ':' -f 1)

# if [ -z "$zerotier_interface" ]; then
#   echo "ZeroTier interface not found."
#   exit 1
# fi

# # Set the standard gateway to the ZeroTier interface
# ip route del default
# ip route add default via $(ip addr show "$zerotier_interface" | grep -Po 'inet \K[\d.]+')

# echo "Set ZeroTier interface '$zerotier_interface' as the standard gateway."

# Changing apporach to just configure the cyconedds to use the zerotier interface

# For now add respective ip apps to do the stuff below:
apt update && apt install -y iproute2

# Find the ZeroTier interface name dynamically
zerotier_interface=$(ip addr show | awk '/^.*: zt/{print $2}' | cut -d ':' -f 1)

if [ -z "$zerotier_interface" ]; then
  echo "ZeroTier interface not found."
  exit 1
fi

echo "Using ZeroTier interface: $zerotier_interface"

# Set the path to your CycloneDDS configuration file
config_file="/cyclonedds.xml"

# Replace the content between <NetworkInterfaceAddress> tags
sed -i "s|<NetworkInterfaceAddress>.*</NetworkInterfaceAddress>|<NetworkInterfaceAddress>$zerotier_interface</NetworkInterfaceAddress>|g" "$config_file"

# Execute the command passed into this entrypoint
exec "$@"