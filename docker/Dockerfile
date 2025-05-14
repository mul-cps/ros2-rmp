ARG ROS_DISTRO=humble
ARG UNDERLAY_WS=/rmp_ws
ARG TARGETPLATFORM


# This file should work for both amd64 and arm64 builds. Because segway did not release some source code we must copy some binaries for the specific architectures.
# That is why we must use some conditional statements to copy over the correct files during build process.
# Variable TARGETPLATFORM should be auomatically created during build process by docker.

########################################
# Base Image for RMP Control #
########################################
FROM ros:${ROS_DISTRO} as base
ENV ROS_DISTRO=${ROS_DISTRO}
#ENV TARGETPLATFORM=$TARGETPLATFORM

SHELL ["/bin/bash", "-c"]

# Create Colcon workspace with external dependencies
RUN echo "update base 26.09.2023 - test"

RUN mkdir -p /rmp_ws/src
WORKDIR /rmp_ws/src
COPY dependencies.arm64.repos .
COPY dependencies.amd64.repos .

# Choose correct sources for architecture:
# Copy platform-specific files
# Use if condition to copy different files for different platforms
#RUN echo "TARGETPLATFORM is $TARGETPLATFORM"
RUN echo "Hardware platform is: $(uname -m)"
RUN uname -a

RUN echo "update base 29.08.2023"

RUN if [ "$(uname -m)" = "x86_64" ]; then \
  echo "Copying files for linux/amd64"; \
  mv dependencies.amd64.repos dependencies.repos; \
  else \
  echo "Copying files for linux/arm64"; \
  mv dependencies.arm64.repos dependencies.repos; \
  fi

#RUN vcs import < dependencies.repos
RUN vcs import < dependencies.repos

# Build the base Colcon workspace, installing dependencies first.
WORKDIR /rmp_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends \
   ros-${ROS_DISTRO}-foxglove-bridge \
  && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y

RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
  && colcon build --symlink-install

# Use Cyclone DDS as middleware and install xacro
RUN apt-get install -y --no-install-recommends \
  ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
  ros-${ROS_DISTRO}-xacro \
  && rm -rf /var/lib/apt/lists/*

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

ENV UNDERLAY_WS=${UNDERLAY_WS}

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Update repository at the end of this build stage
RUN vcs pull src

ENTRYPOINT [ "/entrypoint.sh" ]

###########################################
# Overlay Image for RMP Control #
###########################################
FROM base AS overlay

# Create an overlay Colcon workspace
RUN echo "update overlay 26.09.2023-take-2"
RUN mkdir -p /overlay_ws/src
WORKDIR /overlay_ws/src
COPY overlay.repos .
RUN vcs import < overlay.repos

WORKDIR /overlay_ws

ENV DEBIAN_FRONTEND noninteractive 

RUN source /rmp_ws/install/setup.bash \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install \
    nano \
    ros-humble-robot-localization \
    ros-humble-joint-state-publisher \
    ros-humble-laser-filters -y \
  && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
  && rm -rf /var/lib/apt/lists/*

RUN source /rmp_ws/install/setup.bash \
  && colcon build --symlink-install

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Update repository at the end of this build stage
RUN vcs pull src

ENTRYPOINT [ "/entrypoint.sh" ]

###########################################
# GUI Additions for Ros2 #
###########################################
FROM overlay AS guis

# Install additional GUI tools
RUN source /rmp_ws/install/setup.bash \
  && apt-get update \
  && apt-get install -y --no-install-recommends ros-${ROS_DISTRO}-rviz2 \
  && rm -rf /var/lib/apt/lists/*

# Update repository at the end of this build stage
RUN vcs pull src

# Set up the entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

LABEL org.opencontainers.image.source=https://github.com/bjoernellens1/ros2_rmp

# This is an auto generated Dockerfile for ros:ros1-bridge
# generated from docker_images_ros2/ros1_bridge/create_ros_ros1_bridge_image.Dockerfile.em
FROM ros:eloquent-ros-base-bionic AS bridge

RUN apt update && apt install -y curl gnupg2 lsb-release

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros1-latest.list

# setup keys
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

ENV ROS1_DISTRO=melodic
ENV ROS2_DISTRO=eloquent

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS1_DISTRO}-ros-comm \
    ros-${ROS1_DISTRO}-roscpp-tutorials \
    ros-${ROS1_DISTRO}-rospy-tutorials \
    && rm -rf /var/lib/apt/lists/*

# install ros2 packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS2_DISTRO}-ros1-bridge \
    ros-${ROS2_DISTRO}-demo-nodes-cpp \
    ros-${ROS2_DISTRO}-demo-nodes-py \
    ros-${ROS2_DISTRO}-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

# install downstream packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python-rosdep \
    && rm -rf /var/lib/apt/lists/*

RUN echo "update 04.09.2023-2"
# setup entrypoint
COPY ./docker/bridge_entrypoint.sh /
RUN chmod +x /bridge_entrypoint.sh

# Set up the entrypoint
ENTRYPOINT [ "/bridge_entrypoint.sh" ]

###########################################
# Orbbec                                  #
###########################################
FROM guis AS orbbec

WORKDIR /overlay_ws

RUN cd /overlay_ws/src && git clone https://github.com/orbbec/OrbbecSDK_ROS2.git

RUN sudo apt update && sudo apt -y install libgflags-dev nlohmann-json3-dev  \
  ros-$ROS_DISTRO-image-transport  ros-${ROS_DISTRO}-image-transport-plugins ros-${ROS_DISTRO}-compressed-image-transport \
  ros-$ROS_DISTRO-image-publisher ros-$ROS_DISTRO-camera-info-manager \
  ros-$ROS_DISTRO-diagnostic-updater ros-$ROS_DISTRO-diagnostic-msgs ros-$ROS_DISTRO-statistics-msgs \
  ros-$ROS_DISTRO-backward-ros libdw-dev

RUN cd /overlay_ws && \
  # build release, Default is Debug
  colcon build --event-handlers  console_direct+  --cmake-args  -DCMAKE_BUILD_TYPE=Release