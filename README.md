### GOAL: A collection of Dockerfiles with scripts to build/test/package them

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
conda install -c conda-forge -y pip && conda clean -ay
pip install psrecord matplotlib && pip cache purge
```

### Find best base image for bioinformatics

On the uclacds slurm cluster (10.18.82.18), request 6 threads and 32GB RAM for 8 hours on an interactive node:
srun --nodes=1 --ntasks-per-node=6 --mem 32G --time=08:00:00 --pty bash -i

Benchmark bwa-mem using Clear/Ubuntu/Alpine Linux base images on the tumor FASTQs using 8 threads, 1.8B block size, and other recommended params:
```bash
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) bwa:0.7.17-clear bwa mem -t 8 -K 1800000000 -Y -D 0.05 -R "@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum" -o tum/tum.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) bwa:0.7.17-ubuntu bwa mem -t 8 -K 1800000000 -Y -D 0.05 -R "@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum" -o tum/tum.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) bwa:0.7.17-alpine bwa mem -t 8 -K 1800000000 -Y -D 0.05 -R "@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum" -o tum/tum.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz
```

If we want to record and plot CPU/RAM usage during runtime, we can use psrecord like this (didn't work in WSL2):
```bash
docker run --rm -v $PWD/data:/mnt -v /srv/ref:/mnt/ref -w /mnt -u $(id -u):$(id -g) bwa:0.7.17-clear bwa mem -t 8 -K 1800000000 -Y -D 0.05 -R "@RG\tID:HHC5WBBXY.6\tBC:AACAAGGC+GNCTTGTT\tLB:tum.idtdna\tPL:ILLUMINA\tPU:HHC5WBBXY-AACAAGGC+GNCTTGTT.6\tSM:tum" -o tum/tum.sam ref/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna tum/fastq.clean_DSQ2_R1_001.fastq.gz tum/fastq.clean_DSQ2_R2_001.fastq.gz & sleep 10; psrecord $(docker inspect -f '{{.State.Pid}}' $(docker ps -l --format '{{.ID}}')) --include-children --interval 1 --plot perf_bwa_mem_on_clear.png
```
