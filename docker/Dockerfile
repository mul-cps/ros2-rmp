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
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
 && colcon build --symlink-install \
 && rm -rf /var/lib/apt/lists/* 

# Use Cyclone DDS as middleware
RUN apt-get update && apt-get install -y --no-install-recommends \
 ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
 ros-${ROS_DISTRO}-xacro \
 && rm -rf /var/lib/apt/lists/*

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

RUN source /rmp_ws/install/setup.bash \
 && colcon build --symlink-install \
 && apt-get update \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
 && rm -rf /var/lib/apt/lists/*

# Set up the entrypoint
COPY ./docker/entrypoint.sh /
RUN chmod +x /entrypoint.sh

COPY ./controller_startup.sh /
RUN chmod +x /controller_startup.sh

COPY ./localization_startup.sh /
RUN chmod +x /localization_startup.sh

ENTRYPOINT [ "/entrypoint.sh" ]

# ###########################################
# # Packing it up into a smaller image by starting from scratch and copying related stuff #
# ###########################################
# FROM ros:${ROS_DISTRO}-ros-core AS final
# COPY --from=overlay /overlay_ws/ /overlay_ws/
# COPY --from=overlay /rmp_ws /rmp_ws
# COPY --from=overlay /opt/ros /opt/ros/
# COPY --from=overlay /usr/local/ /usr/local/
# # COPY --from=overlay /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/
# # COPY --from=overlay /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/
# # COPY --from=overlay /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/
# # COPY --from=overlay /lib/x86_64-linux-gnu/librt.so.1 /lib/x86_64-linux-gnu/
# # COPY --from=overlay /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/
# # COPY --from=overlay /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/
# # COPY --from=overlay /lib64/ld-linux-x86-64.so.2 /lib64/

# # Set up environment variables
# ENV LD_LIBRARY_PATH=/usr/local/lib:/opt/ros/${ROS_DISTRO}/lib:/opt/ros/${ROS_DISTRO}/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
# ENV PATH=/opt/ros/${ROS_DISTRO}/bin:$PATH

# # Copy necessary entrypoint and scripts
# COPY ./docker/entrypoint.sh /
# COPY ./controller_startup.sh /
# COPY ./localization_startup.sh /

# # Set permissions for scripts
# RUN chmod +x /entrypoint.sh /controller_startup.sh /localization_startup.sh

# # Set up the entrypoint
# ENTRYPOINT [ "/entrypoint.sh" ]

# LABEL org.opencontainers.image.source=https://github.com/bjoernellens1/ros2_rmp