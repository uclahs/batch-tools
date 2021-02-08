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
conda install -c conda-forge -y pip matplotlib && conda clean -ay
pip install psrecord && pip cache purge
```

::TODO:: Get rootless docker working after having admins install uidmap: https://docs.docker.com/engine/security/rootless/
