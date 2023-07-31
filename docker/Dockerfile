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
SHELL ["/bin/bash", "-c"]

# Create Colcon workspace with external dependencies
RUN mkdir -p /rmp_ws/src
WORKDIR /rmp_ws/src
COPY dependencies.arm64.repos .
COPY dependencies.amd64.repos .

# Choose correct sources for architecture:
# Copy platform-specific files
# Use if condition to copy different files for different platforms
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      echo "Copying files for linux/amd64"; \
      mv dependencies.amd64.repos dependencies.repos; \
    else \
      echo "Copying files for linux/arm64"; \
      mv dependencies.arm64.repos dependencies.repos; \
    fi

RUN vcs import < dependencies.repos
 
# Build the base Colcon workspace, installing dependencies first.
WORKDIR /rmp_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
 && apt-get update -y \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
 && colcon build --symlink-install

# Use Cyclone DDS as middleware
RUN apt-get update && apt-get install -y --no-install-recommends \
 ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
 ros-${ROS_DISTRO}-xacro
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

ENV UNDERLAY_WS=${UNDERLAY_WS}

###########################################
# Overlay Image for Bot Mini Control #
###########################################
FROM base AS overlay
 
# Create an overlay Colcon workspace
RUN mkdir -p /overlay_ws/src
WORKDIR /overlay_ws/src
COPY overlay.repos .
RUN vcs import < overlay.repos

WORKDIR /overlay_ws
# COPY ./tb3_autonomy/ ./src/tb3_autonomy/
# COPY ./tb3_worlds/ ./src/tb3_worlds/
RUN source /rmp_ws/install/setup.bash \
 && colcon build --symlink-install \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
RUN chmod +x /entrypoint.sh

COPY ./controller_startup.sh /
RUN chmod +x /controller_startup.sh

COPY ./localization_startup.sh /
RUN chmod +x /localization_startup.sh

ENTRYPOINT [ "/entrypoint.sh" ]