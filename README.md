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

[Follow these instructions](https://docs.docker.com/get-docker) to install `Docker`. It requires administrative rights, which you normally have on a laptop/workstation. But if not, contact your system administrator to get Docker installed. In shared computers like HPC clusters, they might have [valid concerns](https://duo.com/decipher/docker-bug-allows-root-access-to-host-file-system) against installing Docker. If so, ask them to [follow these instructions](https://sylabs.io/singularity/) to install `Singularity` instead. If they still say no, then use [conda](https://docs.conda.io) to install Singularity in your home directory.

If you don't already have conda, install it into `$HOME/miniconda3` as follows:
```bash
curl -sL https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh -o /tmp/miniconda.sh
sh /tmp/miniconda.sh -bfp $HOME/miniconda3 && rm -f /tmp/miniconda.sh
```

Add this to your `~/.bashrc` so that the `conda` command is always available when you login:
```bash
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . $HOME/miniconda3/etc/profile.d/conda.sh
fi
```

Login again, activate the conda base environment, then install singularity and some of its dependencies:
```bash
conda activate
conda install -c conda-forge -y singularity squashfs-tools && conda clean -ay
```

Locate the singularity config file using `find $HOME/miniconda3/etc -name singularity.conf` and open it up in a text editor. Uncomment the line starting with `# mksquashfs path` and point it to the miniconda bin folder. Make sure there is a `/` at the end of the path. For example, mine looks like this:
```
mksquashfs path = /home/ckandoth/miniconda3/bin/
```

Now try running `singularity exec docker://ghcr.io/ucladx/bwa:0.7.17 bwa mem` and it should download the Docker image, convert it into a Singularity `SIF` image, convert that into a sandbox in user-namespace where `bwa mem` runs in a container. If you get a `Failed to create user namespace` error, then you're out of luck. Ask your boss to convince sysadmins to get you a full-featured Singularity or Docker installation.

### Find best base image

On the UCLA-CDS Slurm cluster, put [the GRCh38 FASTA and BWA index](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/) into `/hot/ref/GRCh38/bwa` and put a pair of 150x tumor exome FASTQs in `/hot/users/ckandoth/wxs/tum`. On a Linux VM or PC where we have sudo rights, put GRCh38 files under `/srv/ref` and the FASTQs in `$PWD/data/tum`.

Basic template for requesting Slurm resources and submitting a `docker run` command:
```bash
sbatch --chdir=/hot/users/ckandoth/wxs --output=tum/tum.out --error=tum/tum.err --nodes=1 --ntasks-per-node=6 --mem=32G --time=04:00:00 --wrap="docker run --help"
```

Benchmark bwa-mem using Clear/Ubuntu/Alpine Linux base images on the tumor FASTQs using 6 threads, 1.8B block size, and other recommended params:
```bash
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-clear bwa mem -t 6 -K 1800000000 -Y -D 0.05 -o tum/tum_clear.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-ubuntu bwa mem -t 6 -K 1800000000 -Y -D 0.05 -o tum/tum_ubuntu.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-alpine bwa mem -t 6 -K 1800000000 -Y -D 0.05 -o tum/tum_alpine.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz
```

These are runtimes/cputimes reported by bwa-mem on various configurations:
```
6 threads and 30GB RAM on 2x18-core Intel Xeon Platinum 8168 running Linux kernel 3.10.0 (CentOS7 node on UCLA-CDS Slurm Cluster):
Real time: 5355.948 sec; CPU: 31307.439 sec; Docker: 20.10.3; Image: clearlinux
Real time: 5300.269 sec; CPU: 31650.502 sec; Docker: 20.10.3; Image: ubuntu
Real time: 5534.129 sec; CPU: 32494.189 sec; Docker: 20.10.3; Image: alpine

6 threads and 30GB RAM on 6-core Intel Core i5-8400 running Linux kernel 5.8.0 (Ubuntu Desktop with kernel mitigations=off)
Real time: 3876.885 sec; CPU: 22865.751 sec; Docker: 20.10.3; Image: clearlinux
Real time: 4470.371 sec; CPU: 26363.596 sec; Docker: 20.10.3; Image: ubuntu
Real time: 4509.992 sec; CPU: 26454.246 sec; Docker: 20.10.3; Image: alpine

6 threads and 30GB RAM on 8-core Intel Xeon W-2145 running Linux kernel 5.4.72 (Windows 10 Workstation with WSL2 Ubuntu)
Real time: 4698.946 sec; CPU: 28483.269 sec; Docker: 20.10.2; Image: clearlinux
Real time: 4686.611 sec; CPU: 28366.192 sec; Docker: 20.10.2; Image: ubuntu
Real time: 4727.225 sec; CPU: 28619.633 sec; Docker: 20.10.2; Image: alpine

24 threads and 30GB RAM on 2x18-core Intel Xeon Platinum 8168 running Linux kernel 3.10.0 (CentOS7 node on UCLA-CDS Slurm Cluster):
Real time: 2200.098 sec; CPU: 43076.075 sec; Docker: 20.10.3; Image: clearlinux
Real time: 2572.758 sec; CPU: 44100.774 sec; Docker: 20.10.3; Image: ubuntu
Real time: 2478.718 sec; CPU: 44758.327 sec; Docker: 20.10.3; Image: alpine
```

To record and plot CPU/RAM usage during runtime, install matplotlib and [psrecord](https://github.com/astrofrog/psrecord); then run psrecord at the same time as bwa-mem like this (does not work in WSL2):
```bash
pip install matplotlib psrecord
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17 bwa mem -t 6 -K 1800000000 -Y -D 0.05 -o tum/tum.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz & sleep 1; psrecord $(docker inspect -f '{{.State.Pid}}' $(docker ps -l --format '{{.ID}}')) --include-children --interval 1 --plot data/tum/perf_bwa_mem.png
```

::TODO:: Repeat these under various cpu/mem/disk conditions, plot mean/SD, and also try [sbatch --profile](https://slurm.schedmd.com/hdf5_profile_user_guide.html).
