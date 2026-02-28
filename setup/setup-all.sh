#!/usr/bin/bash

# mise
mise trust -y
mise settings add idiomatic_version_file_enable_tools "[]"
mise install -y

# Python
bash /workspace/setup/uv-sync.sh

# R
R -e "install.packages('renv', repos = 'http://cran.rstudio.com/')"
Rscript /workspace/setup-renv.R 

# Julia
julia --project='/workspace' -e 'using Pkg; Pkg.instantiate(); Pkg.build("IJulia")'

# Bun
bun install

# Jupyter
bash /workspace/setup/update-jupyter-template.sh
