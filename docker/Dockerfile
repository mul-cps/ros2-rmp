ARG ROS_DISTRO=humble
ARG UNDERLAY_WS=/rmp_ws
ARG TARGETPLATFORM


# This file should work for both amd64 and arm64 builds. Because segway did not release some source code we must copy some binaries for the specific architectures.
# That is why we must use some conditional statements to copy over the correct files during build process.
# Variable TARGETPLATFORM should be auomatically created during build process by docker.

########################################
# Base Image for Bot Mini Control #
########################################
FROM ros:${ROS_DISTRO} as base
ENV ROS_DISTRO=${ROS_DISTRO}
#ENV TARGETPLATFORM=$TARGETPLATFORM

SHELL ["/bin/bash", "-c"]

# Create Colcon workspace with external dependencies
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
RUN vcs import < dependencies.repos;

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
RUN mkdir -p /overlay_ws/src
WORKDIR /overlay_ws/src
COPY overlay.repos .
RUN vcs import < overlay.repos

WORKDIR /overlay_ws

RUN echo "update overlay 22.08.2023"

RUN source /rmp_ws/install/setup.bash \
  && apt-get update \
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


### Added for bridging
# FROM ubuntu:focal as bridge

# SHELL ["/bin/bash", "-c"]

# ENV DEBIAN_FRONTEND noninteractive
# ENV ROS_DISTRO=foxy

# RUN locale
# RUN apt-get update && apt-get install -y locales
# RUN locale-gen en_US en_US.UTF-8
# RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# ENV LANG=en_US.UTF-8

# RUN locale 

# RUN apt-get update && apt-get install -y --no-install-recommends \
#   curl \
#   gnupg2 \
#   lsb-release \
#   software-properties-common \
#   && add-apt-repository universe

# RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
# RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# # Install common packages
# RUN apt-get update && apt-get install -y \
#   python3-flake8-docstrings \
#   python3-pip \
#   python3-pytest-cov \
#   ros-dev-tools

# RUN mkdir -p /root/ros2_foxy/src
# WORKDIR /root/ros2_foxy
# RUN vcs import --input https://raw.githubusercontent.com/ros2/ros2/${ROS_DISTRO}/ros2.repos src 
#   #&& vcs import --input https://raw.githubusercontent.com/ros2/rmw_fastrtps/${ROS_DISTRO}/rmw_fastrtps.repos ~/ros2_humble/src \
#   #&& vcs import --input https://raw.githubusercontent.com/ros2/rmw_cyclonedds/${ROS_DISTRO}/rmw_cyclonedds.repos ~/ros2_humble/src

# ARG RTI_NC_LICENSE_ACCEPTED=yes # must accept license agreement for RTI Connext DDS

# RUN apt-get update && apt-get upgrade -y \
#   && rosdep init \
#   && rosdep update \
#   && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y --skip-keys "console_bridge fastcdr fastrtps rti-connext-dds-5.3.1 urdfdom_headers"

# RUN colcon build --symlink-install

# # Create Colcon workspace with external dependencies
# RUN mkdir -p /rmp_ws/src
# WORKDIR /rmp_ws/src
# COPY dependencies.arm64.repos .
# COPY dependencies.amd64.repos .

# # Choose correct sources for architecture:
# # Copy platform-specific files
# # Use if condition to copy different files for different platforms
# #RUN echo "TARGETPLATFORM is $TARGETPLATFORM"
# RUN echo "Hardware platform is: $(uname -m)"
# RUN uname -a

# RUN if [ "$(uname -m)" = "x86_64" ]; then \
#   echo "Copying files for linux/amd64"; \
#   mv dependencies.amd64.repos dependencies.repos; \
#   else \
#   echo "Copying files for linux/arm64"; \
#   mv dependencies.arm64.repos dependencies.repos; \
#   fi

# #RUN vcs import < dependencies.repos
# RUN vcs import < dependencies.repos;

# # Build the base Colcon workspace, installing dependencies first.
# WORKDIR /rmp_ws
# RUN source /home/root/ros2_foxy/install/setup.bash \
#   && apt-get update -y \
#   && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y

# RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
#   && colcon build --symlink-install

# ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# # Set up the entrypoint
# COPY ./docker/entrypoint.sh /
# RUN chmod +x /entrypoint.sh

# ENTRYPOINT [ "/entrypoint.sh" ]

# This is an auto generated Dockerfile for ros:ros1-bridge
# generated from docker_images_ros2/ros1_bridge/create_ros_ros1_bridge_image.Dockerfile.em
FROM ros:eloquent-ros-base-bionic AS bridge

RUN apt update && apt install -y curl gnupg2 lsb-release

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros1-latest.list

# setup keys
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

ENV ROS1_DISTRO melodic
ENV ROS2_DISTRO eloquent

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