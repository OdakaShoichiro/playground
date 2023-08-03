FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

ARG UNAME=odakas
ARG UID=1000

ARG JULIA_VERSION="1.9.2"
ARG JULIA_VERSION_MAJOR_MINOR="1.9"

ARG NODE_VERSION_MAJOR="18"

ARG JUPYTER_PORT=8888

ENV PATH="/opt/julia-${JULIA_VERSION}/bin:${PATH}"

ENV TZ=Asia/Tokyo

ENV JULIA_PROJECT="/workspace"
ENV JULIA_DEPOT_PATH="/workspace/julia_pkgs"

# Install apt packages
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update && \
    apt upgrade -y ca-certificates && \
    apt install -y --no-install-recommends \
    cmake \
    curl \
    dirmngr \
    fonts-ipafont \
    gfortran \
    git \
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
    texlive-plain-generic \
    texlive-xetex \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver "keyserver.ubuntu.com" --recv-keys "E298A3A825C0D65DFD57CBB651716619E084DAB9" && \
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/' && \
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION_MAJOR}.x" | bash -

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
    nodejs \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

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

EXPOSE ${JUPYTER_PORT}
WORKDIR /workspace
