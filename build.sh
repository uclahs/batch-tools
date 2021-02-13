#/bin/sh

set -e

# If there are unstaged/uncommitted/untracked files, then don't proceed further
if [[ $(git diff-index HEAD --) ]]; then
    echo "ERROR: Unstaged or uncommitted changes found. Commit everything before using this script."
    exit 1
fi
if [[ $(git ls-files --exclude-standard --others) ]]; then
    echo "ERROR: Untracked files found. Commit your changes before using this script."
    exit 1
fi

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
