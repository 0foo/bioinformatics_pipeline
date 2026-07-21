FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install basic system utilities (compilers and git are no longer needed)
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

# 3. Install Miniconda
RUN wget -qO /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh

# 4. Configure paths so Conda and NCBI tools are globally available
ENV PATH="/opt/conda/bin:/opt/bin:$PATH"

# 5. Install the entire bioinformatics stack via Conda
# This automatically installs EarlGrey, RepeatMasker, RepeatModeler, RECON, RepeatScout, TRF, BLAST, BEDtools, Snakemake, and all Perl/Python dependencies.
RUN conda config --add channels defaults \
    && conda config --add channels bioconda \
    && conda config --add channels conda-forge \
    && conda install -y earlgrey repeatmodeler=2.0.7 snakemake \
    && conda clean -a -y

CMD ["/bin/bash"]