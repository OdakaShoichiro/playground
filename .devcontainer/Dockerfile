FROM nvidia/cuda:12.2.0-devel-ubuntu20.04 

# FROM ubuntu:20.04

ARG UID=1000

ARG JULIA_VERSION="1.9.1"
ARG JULIA_VERSION_MAJOR_MINOR="1.9"

ARG JUPYTER_PORT=8888

ENV PATH="/opt/julia-${JULIA_VERSION}/bin:${PATH}"

ENV TZ=Asia/Tokyo

ENV JULIA_DEPOT_PATH=/workspace/julia_pkgs

COPY .devcontainer/installed_packages.list /tmp/

ENV DEBIAN_FRONTEND=noninteractive

# Install apt packages
RUN apt update && \
    apt upgrade -y ca-certificates && \
    apt install -y --no-install-recommends \
    cmake \
    curl \
    dirmngr \
    fonts-ipafont \
    gfortran \
    git \
    nodejs \
    npm \
    libblas-dev \
    libcurl4-openssl-dev \
    liblapack-dev \
    libssl-dev \
    libxml2-dev \
    pandoc \
    software-properties-common \
    sudo \
    texlive \
    texlive-lang-japanese \
    texlive-xetex \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'

RUN apt update && \
    apt upgrade -y ca-certificates && \
    apt install -y --no-install-recommends \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=newt

# Add user for develpment
RUN useradd -m -s /bin/bash -G sudo odakas --uid "${UID}" && \
    echo 'odakas ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER odakas
WORKDIR /home/odakas

# Install Rye
RUN curl -sSf https://rye-up.com/get | RYE_NO_AUTO_INSTALL=1 RYE_INSTALL_OPTION="--yes" bash && \
    echo 'source "$HOME/.rye/env"' >> ~/.bashrc && \
    echo 'if [ -d "/workspace/.venv/bin" ]; then source /workspace/.venv/bin/activate; fi' >> ~/.bashrc

# Install renv
RUN sudo R -e "install.packages('renv', repos = 'http://cran.rstudio.com/')"

# Install Julia & libraries
RUN wget -O julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION_MAJOR_MINOR}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    sudo tar xzf julia.tar.gz -C /usr/local --strip-components=1 && \
    rm julia.tar.gz && \
    julia -e 'using Pkg; Pkg.add("IJulia")'

# Expose Jupyter port
EXPOSE ${JUPYTER_PORT}

# Set working directory
WORKDIR /workspace
