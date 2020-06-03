#!/bin/bash
set -ev

# !!!NOTE!!! This is intended to run as root.

# Additional setup to perform after building and installing Sage
# This is broken out into a separate script so it can be run as
# a separate step in the Dockerfile without performing a full
# rebuild.
SAGE_SRC_TARGET=${1%/}

# Add aliases for sage and sagemath
ln -sf "${SAGE_SRC_TARGET}/sage/sage" /usr/bin/sage
ln -sf "${SAGE_SRC_TARGET}/sage/sage" /usr/bin/sagemath

# Put scripts to start gap, gp, maxima, ... in /usr/bin
sage --nodotsage -c "install_scripts('/usr/bin')"

# Install additional Python packages into the sage Python distribution...
# Install terminado for terminal support in the Jupyter Notebook
sudo -H -u sage sage -pip install terminado
