#/bin/sh

set -e

# Look recursively for Dockerfiles, and run a "docker build" command grepped out from each
current_dir=$(pwd)
docker_files=$(find -type f -name Dockerfile)
for docker_file in $docker_files; do
    build_dir=$(dirname $docker_file)
    build_cmd=$(grep -E "^# BUILD_CMD" $docker_file | cut -d: -f2-)
    cd $build_dir
    $build_cmd
    cd $current_dir
done

# Clean up intermediate images created by the multi-stage builds
docker image prune -f
