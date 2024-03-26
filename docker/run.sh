PROJECT_DIR=$PWD
echo "$PROJECT_DIR"

docker container rm -f voxelmap
docker run -it --name voxelmap \
           -v "$PROJECT_DIR":/workspace/src/voxel \
           voxelmap:v1.0