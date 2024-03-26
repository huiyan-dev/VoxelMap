# some custom catkin_package will install here
ARG THIRD_LIBRARY_ROOT=/third_libs

# stage1: -------------------------- build livox_driver
FROM osrf/ros:noetic-desktop-full as build_livox_driver
ARG THIRD_LIBRARY_ROOT
ARG PACKAGE_NAME=Livox-SDK-2.3.0
COPY docker/3rdparty/$PACKAGE_NAME $THIRD_LIBRARY_ROOT/$PACKAGE_NAME
WORKDIR $THIRD_LIBRARY_ROOT/$PACKAGE_NAME
RUN mkdir livox_sdk_build && cd livox_sdk_build && \
        cmake .. && make -j16 && sudo make install
ARG PACKAGE_NAME=livox_ros_driver
COPY docker/3rdparty/$PACKAGE_NAME $THIRD_LIBRARY_ROOT/ws_livox/src/$PACKAGE_NAME
WORKDIR $THIRD_LIBRARY_ROOT/ws_livox
RUN /bin/bash -c 'source /opt/ros/noetic/setup.bash && catkin_make && catkin_make install'

# stage2: -------------------------- build project
FROM osrf/ros:noetic-desktop-full

# install ceres-solver
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        cmake libgoogle-glog-dev libgflags-dev \
        libatlas-base-dev libeigen3-dev libsuitesparse-dev
ARG THIRD_LIBRARY_ROOT=/third_libs
ARG PACKAGE_NAME=ceres-solver-2.2.0
COPY docker/3rdparty/$PACKAGE_NAME $THIRD_LIBRARY_ROOT/$PACKAGE_NAME
WORKDIR $THIRD_LIBRARY_ROOT/$PACKAGE_NAME
RUN mkdir ceres-bin && cd ceres-bin && cmake .. && make -j16 && sudo make install

# copy livox_driver
COPY --from=build_livox_driver /usr/local/ /usr/local/
COPY --from=build_livox_driver $THIRD_LIBRARY_ROOT/ws_livox/install  /catkin_ws_libs/install
RUN ldconfig
# ros entrypoint
WORKDIR /workspace
COPY docker/ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]