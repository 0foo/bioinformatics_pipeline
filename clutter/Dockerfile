FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system utilities, compilers, Perl modules, and core binaries
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    unzip \
    curl \
    git \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# 2. Pre-stage the NCBI datasets utility tools
RUN mkdir -p /opt/bin \
    && curl -sS -L -o /opt/bin/datasets https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets \
    && curl -sS -L -o /opt/bin/dataformat https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat \
    && chmod +x /opt/bin/datasets /opt/bin/dataformat

# 3. Download and set up all pipeline driver dependencies in /opt/drivers
RUN mkdir -p /opt/drivers

# Install RepeatScout from official source tarball
RUN wget http://www.repeatmasker.org/RepeatScout-1.0.6.tar.gz -O /opt/drivers/RepeatScout.tar.gz \
    && tar -xzvf /opt/drivers/RepeatScout.tar.gz -C /opt/drivers/ \
    && mv /opt/drivers/RepeatScout-1.0.6 /opt/drivers/repeatscout_local \
    && cd /opt/drivers/repeatscout_local && make \
    && rm /opt/drivers/RepeatScout.tar.gz

# Install RECON
RUN wget http://www.repeatmasker.org/RECON-1.08.tar.gz -O /opt/drivers/recon.tar.gz \
    && tar -xzvf /opt/drivers/recon.tar.gz -C /opt/drivers/ \
    && mv /opt/drivers/RECON-1.08 /opt/drivers/recon_local \
    && cd /opt/drivers/recon_local/src && make && make install \
    && rm /opt/drivers/recon.tar.gz

# Install RepeatMasker
RUN git clone https://github.com/Dfam-consortium/RepeatMasker.git /opt/drivers/RepeatMasker

# Install RepeatModeler
RUN git clone https://github.com/Dfam-consortium/RepeatModeler.git /opt/drivers/RepeatModeler

# Install EarlGrey main tool (Fixed script filename casing)
RUN git clone https://github.com/TobyBaril/EarlGrey.git /opt/drivers/EarlGrey \
    && chmod +x /opt/drivers/EarlGrey/earlGrey

RUN sed -i 's|SCRIPT_DIR=/data/toby/EarlGrey/scripts/|SCRIPT_DIR=/opt/drivers/EarlGrey/scripts/|g' /opt/drivers/EarlGrey/earlGrey*

# 1. Install system utilities, compilers, Perl modules, and core binaries
RUN apt-get update && apt-get install -y --no-install-recommends \
    snakemake \
    ncbi-blast+ \
    bedtools \
    trf \
    libsqlite3-dev \
    hmmer \
    libfile-which-perl \
    libtext-soundex-perl \
    libjson-perl \
    python3-pip \ 
    python3-h5py \
    && rm -rf /var/lib/apt/lists/*


# 4. Configure internal environment boundaries and system paths
ENV PATH="/opt/bin:\
/opt/drivers/EarlGrey:\
/opt/drivers/RepeatMasker:\
/opt/drivers/RepeatModeler:\
/opt/drivers/repeatscout_local:\
/opt/drivers/recon_local/bin:$PATH"

ENV PERL5LIB="/opt/drivers/RepeatMasker:/opt/drivers/RepeatModeler"
ENV SCRIPT_DIR="/opt/drivers/EarlGrey/scripts"

CMD ["/bin/bash"]