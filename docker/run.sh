PROJECT_DIR=$PWD
echo "$PROJECT_DIR"
docker run -it --name voxelmap \
           -v "$PROJECT_DIR":/workspace/src/voxel \
           registry.cn-hangzhou.aliyuncs.com/huiyan/dev:noetic-desktop-full