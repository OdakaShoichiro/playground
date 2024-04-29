FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ARG UNAME=odakas
ARG UID=1000

ARG JULIA_VERSION="1.10.2"
ARG JULIA_VERSION_MAJOR_MINOR="1.10"

ARG NODE_VERSION_MAJOR="22"

ENV PATH="/opt/julia-${JULIA_VERSION}/bin:${PATH}"

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
    fonts-ipafont \
    gfortran \
    git \
    file \
    libblas-dev \
    libcurl4-openssl-dev \
    liblapack-dev \
    libmecab-dev \
    libssl-dev \
    libxml2-dev \
    mecab \
    mecab-ipadic-utf8 \
    pandoc \
    software-properties-common \
    sudo \
    swig \
    texlive \
    texlive-lang-japanese \
    texlive-plain-generic \
    texlive-xetex \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Add R & Node.js repositories
RUN gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/R.gpg \
    --keyserver "keyserver.ubuntu.com" --recv-keys "E298A3A825C0D65DFD57CBB651716619E084DAB9" && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/R.gpg] https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" | \
    sudo tee /etc/apt/sources.list.d/R.list > /dev/null && \
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION_MAJOR}.x" | bash -

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
    nodejs \
    r-base \
    r-base-dev \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

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

ENV DEBIAN_FRONTEND="newt"

# Add user for development
RUN useradd -m -s /bin/bash -G sudo "${UNAME}" --uid "${UID}" && \
    echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER odakas
WORKDIR /home/odakas

# Install Rye
RUN curl -sSf "https://rye-up.com/get" | RYE_NO_AUTO_INSTALL=1 RYE_INSTALL_OPTION="--yes" bash && \
    echo 'source "$HOME/.rye/env"' >> ~/.bashrc && \
    echo 'if [ -d "/workspace/.venv/bin" ]; then source /workspace/.venv/bin/activate; fi' >> ~/.bashrc

# Install renv
RUN sudo R -e "install.packages('renv', repos = 'http://cran.rstudio.com/')"

# Install Julia
RUN wget -O julia.tar.gz "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION_MAJOR_MINOR}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    sudo tar xzf julia.tar.gz -C /usr/local --strip-components=1 && \
    rm julia.tar.gz

WORKDIR /workspace
