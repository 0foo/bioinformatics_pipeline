#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# 1. Install basic system utilities (requires sudo)
echo ">>> Installing system dependencies..."
sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    jq \
    unzip \
    curl \
    wget \
    ca-certificates \
    && sudo rm -rf /var/lib/apt/lists/*

WORKSPACE="/workspace"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# 2. Pre-stage the NCBI datasets utility tools
echo ">>> Installing NCBI datasets tools..."
sudo mkdir -p /opt/bin
sudo curl -sS -L -o /opt/bin/datasets https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets
sudo curl -sS -L -o /opt/bin/dataformat https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat
sudo chmod +x /opt/bin/datasets /opt/bin/dataformat

# 3. Install Miniforge
echo ">>> Installing Miniforge..."
wget -qO /tmp/miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash /tmp/miniforge.sh -b -p /opt/conda
rm /tmp/miniforge.sh

# 4. Configure paths
export PATH="/opt/conda/envs/bioenv/bin:/opt/conda/bin:/opt/bin:$PATH"

# 5. Configure channels and create a dedicated environment with Python 3.11
echo ">>> Creating conda environment and installing bioinformatics tools..."
conda config --add channels bioconda
conda config --add channels conda-forge
mamba create -n bioenv -y python=3.11 earlgrey repeatmodeler=2.0.7
mamba clean -a -y

echo ">>> Setup completed successfully."