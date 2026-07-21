FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install basic system utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    unzip \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# 2. Pre-stage the NCBI datasets utility tools
RUN mkdir -p /opt/bin \
    && curl -sS -L -o /opt/bin/datasets https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets \
    && curl -sS -L -o /opt/bin/dataformat https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat \
    && chmod +x /opt/bin/datasets /opt/bin/dataformat

# 3. Install Miniforge (includes Mamba for lightning-fast dependency solving)
RUN wget -qO /tmp/miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
    && bash /tmp/miniforge.sh -b -p /opt/conda \
    && rm /tmp/miniforge.sh

# 4. Configure paths so Conda/Mamba and NCBI tools are globally available
ENV PATH="/opt/conda/bin:/opt/bin:$PATH"

# 5. Configure channels, accept ToS, and install the stack using Mamba
RUN conda config --add channels defaults \
    && conda config --add channels bioconda \
    && conda config --add channels conda-forge \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r \
    && mamba install -y earlgrey repeatmodeler=2.0.7 \
    && mamba clean -a -y

CMD ["/bin/bash"]