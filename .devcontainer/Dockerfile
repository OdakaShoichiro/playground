FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ARG UNAME=odakas
ARG UID=1000

ENV TZ=Asia/Tokyo

ENV JULIA_PROJECT="/workspace"
ENV JULIA_DEPOT_PATH="/workspace/julia_pkgs"

# Install apt packages
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update && \
    apt upgrade -y ca-certificates && \
    apt install -y --no-install-recommends \
    clang \
    cmake \
    curl \
    dirmngr \
    file \
    fontconfig \
    fonts-ipafont \
    gfortran \
    git \
    libbz2-dev \
    libblas-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfribidi-dev\
    libharfbuzz-dev \
    liblapack-dev \
    libmecab-dev \
    libreadline-dev \
    libssl-dev \
    libtiff5-dev \
    libx11-dev \
    libxml2-dev \
    libxt-dev \
    mecab \
    mecab-ipadic-utf8 \
    software-properties-common \
    sudo \
    swig \
    texlive \
    texlive-lang-japanese \
    texlive-plain-generic \
    texlive-xetex \
    tzdata \
    unzip \
    vim \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

# install mise
RUN install -dm 755 /etc/apt/keyrings && \
    wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list && \
    apt update && \
    sudo apt install -y mise && \
    echo 'eval "$(/usr/bin/mise activate bash)"' >> ~/.bashrc

# Add fonts
RUN wget -O MyricaM.zip "https://github.com/tomokuni/Myrica/raw/master/product/MyricaM.zip" && \
    unzip MyricaM.zip && \
    cp MyricaM.TTC /usr/share/fonts/truetype && \
    mkdir mkdir /usr/share/fonts/truetype/myrica && \
    cp MyricaM.TTC /usr/share/fonts/truetype/myrica && \
    fc-cache -fv

# Install mecab-ipadic-neologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git && \
    mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -a -y

# Add user for development
RUN useradd -m -s /bin/bash -G sudo "${UNAME}" --uid "${UID}" && \
    echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV DEBIAN_FRONTEND="newt"

USER odakas
WORKDIR /workspace
