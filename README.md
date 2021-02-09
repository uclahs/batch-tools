### GOAL: A collection of Dockerfiles with scripts to build/test/package them

### Quick start

After building and testing, images are pushed into [github.com/orgs/ucladx/packages](https://github.com/orgs/ucladx/packages), which can be run using `docker` or `singularity` like this:
```bash
docker run --rm ghcr.io/ucladx/bwa:0.7.17 bwa
singularity exec docker://ghcr.io/ucladx/bwa:0.7.17 bwa
```

### Prerequisites

If you don't already have conda, install it into `$HOME/miniconda3` as follows:
```bash
curl -sL https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh -o /tmp/miniconda.sh
sh /tmp/miniconda.sh -bfp $HOME/miniconda3 && rm -f /tmp/miniconda.sh
```

Add this to your `~/.bashrc` so that the "conda" command is available when you login:
```bash
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . $HOME/miniconda3/etc/profile.d/conda.sh
fi
```

Login again or run `source ~/.bashrc`, activate the conda base env, then install some basic prerequisites:
```bash
conda activate
conda install -c conda-forge -y pip singularity && conda clean -ay
```

### Find best base image for bwa-mem

On the UCLA-CDS Slurm cluster, download [the GRCh38 FASTA and BWA index](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/) into `/hot/ref/GRCh38/bwa` and put a pair of 150x tumor exome FASTQs in `/hot/users/ckandoth/wxs/tum`. On a Linux VM or PC where you have sudo rights, store GRCh38 files under `/srv/ref` and the FASTQs in `$PWD/data/tum`.

Basic template for requesting Slurm resources and submitting a `docker run` command:
```bash
sbatch --chdir=$PWD --output=bwa_mem.out --error=bwa_mem.err --nodes=1 --ntasks-per-node=1 --mem=4G --time=01:00:00 --wrap="docker run --rm -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-clear bwa mem"
```

Benchmark bwa-mem using Clear/Ubuntu/Alpine Linux base images on the tumor FASTQs using 24 threads, 1.8B block size, and other recommended params:
```bash
sbatch --chdir=/hot/users/ckandoth/wxs --output=tum/tum_clear.out --error=tum/tum_clear.err --nodes=1 --ntasks-per-node=24 --mem=32G --time=04:00:00 --wrap="docker run --rm -v /hot/users/ckandoth/wxs:/mnt -v /hot/ref/GRCh38/bwa:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-clear bwa mem -t 24 -K 1800000000 -Y -D 0.05 -R '@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum' -o tum/tum_clear.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz"
sbatch --chdir=/hot/users/ckandoth/wxs --output=tum/tum_ubuntu.out --error=tum/tum_ubuntu.err --nodes=1 --ntasks-per-node=24 --mem=32G --time=04:00:00 --wrap="docker run --rm -v /hot/users/ckandoth/wxs:/mnt -v /hot/ref/GRCh38/bwa:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-ubuntu bwa mem -t 24 -K 1800000000 -Y -D 0.05 -R '@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum' -o tum/tum_ubuntu.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz"
sbatch --chdir=/hot/users/ckandoth/wxs --output=tum/tum_alpine.out --error=tum/tum_alpine.err --nodes=1 --ntasks-per-node=24 --mem=32G --time=04:00:00 --wrap="docker run --rm -v /hot/users/ckandoth/wxs:/mnt -v /hot/ref/GRCh38/bwa:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-alpine bwa mem -t 24 -K 1800000000 -Y -D 0.05 -R '@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum' -o tum/tum_alpine.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz"
```

These are runtimes/cputimes reported by bwa-mem on various configurations:
```
24 threads and 30GB RAM on 18-core Intel Xeon Platinum 8168 running Linux kernel 3.10.0 (CentOS7 on UCLA-CDS Slurm Cluster):
Real time: 2200.098 sec; CPU: 43076.075 sec; Docker: 20.10.3; Image: clearlinux
Real time: 2572.758 sec; CPU: 44100.774 sec; Docker: 20.10.3; Image: ubuntu
Real time: 2478.718 sec; CPU: 44758.327 sec; Docker: 20.10.3; Image: alpine

6 threads and 30GB RAM on 18-core Intel Xeon Platinum 8168 running Linux kernel 3.10.0 (CentOS7, UCLA-CDS Slurm Cluster):
Real time: 5355.948 sec; CPU: 31307.439 sec; Docker: 20.10.3; Image: clearlinux
Real time: 5300.269 sec; CPU: 31650.502 sec; Docker: 20.10.3; Image: ubuntu
Real time: 5534.129 sec; CPU: 32494.189 sec; Docker: 20.10.3; Image: alpine

6 threads and 30GB RAM on 6-core Intel Core i5-8400 running Linux kernel 5.8.0 (mitigations=off, Ubuntu 20.04, Linux workstation)
Real time: 3876.885 sec; CPU: 22865.751 sec; Docker: 20.10.3; Image: clearlinux
Real time: 4470.371 sec; CPU: 26363.596 sec; Docker: 20.10.3; Image: ubuntu
Real time: 4509.992 sec; CPU: 26454.246 sec; Docker: 20.10.3; Image: alpine

6 threads and 30GB RAM on 8-core Intel Xeon W-2145 running Linux kernel 5.4.72 (WSL2, Ubuntu 20.04, Windows 10 laptop)
Real time: 4698.946 sec; CPU: 28483.269 sec; Docker: 20.10.2; Image: clearlinux
Real time: 4686.611 sec; CPU: 28366.192 sec; Docker: 20.10.2; Image: ubuntu
Real time: 4727.225 sec; CPU: 28619.633 sec; Docker: 20.10.2; Image: alpine
```

::TODO:: Test under various cpu/mem/disk conditions, plot mean/SD, and also try [sbatch --profile](https://slurm.schedmd.com/hdf5_profile_user_guide.html).

To record and plot CPU/RAM usage during runtime, run psrecord at the same time like this (does not work in WSL2):
```bash
pip install psrecord matplotlib && pip cache purge
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) ghcr.io/ucladx/bwa:0.7.17-clear bwa mem -t 6 -K 1800000000 -Y -D 0.05 -R '@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum' -o tum/tum_clear.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz & sleep 1; psrecord $(docker inspect -f '{{.State.Pid}}' $(docker ps -l --format '{{.ID}}')) --include-children --interval 1 --plot tum/perf_bwa_mem_on_clear.png
```
