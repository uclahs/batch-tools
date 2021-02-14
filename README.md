### Quick start

Find an image at [github.com/orgs/ucladx/packages](https://github.com/orgs/ucladx/packages) and run it using `docker` or `singularity` like this:
```bash
docker run --rm -u $(id -u):$(id -g) ghcr.io/ucladx/<image>:<version> <command>
singularity exec docker://ghcr.io/ucladx/<image>:<version> <command>
```

For example, to display `bwa mem` command-line usage using the `ucladx/bwa:0.7.17` image:
```bash
docker run --rm -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17 bwa mem
singularity exec docker://ghcr.io/ucladx/bwa:0.7.17 bwa mem
```

### Install docker or singularity

[Follow these instructions](https://docs.docker.com/get-docker) to install `docker`. It requires administrative rights, which you normally have on a laptop/workstation. But if not, contact your system administrator to get Docker installed. In shared computers like HPC clusters, they might have [valid concerns](https://duo.com/decipher/docker-bug-allows-root-access-to-host-file-system) against installing Docker. If so, ask them to [follow these instructions](https://sylabs.io/singularity/) to install `singularity` instead. If they still say no, then ask your boss to convince them.
