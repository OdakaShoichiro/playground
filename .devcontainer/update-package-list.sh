#!/usr/bin/bash

dpkg-query -W -f='${Package}=${Version}\n' > \
    /workspace/.devcontainer/installed_packages.list
