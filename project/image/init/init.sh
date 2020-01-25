#!/bin/bash
set -e
date -Ins

# Setup the environment.  This is EVERYTHING that the user sees, because we run init.sh
# with the optionenv -i.  We do this to have a clear whitelist of the user's environment,
# since Kubernetes very annoyingly puts a ton of potentially sensitive invormation
# in the environment.
#
# Some comments about the vars below:
#
# SMC                 = where project server stores its temp files
# SMC_ROOT            = where cocalc source code is located
# NODE_PATH           = load path for project server code
# COCALC_USERNAME     = username that project runs as (TODO: do NOT change).
# PATH                = load path for code
# PYTHONPATH          = do not set it, because it mixes up libraries between python2 and 3
#                       instead, use a *.pth file, see k8s_build.py!
# $1                  = the project's UUID

PROJECT_ID=$1

# Note: do not use the comment '#' sign *inside* any values! (assumed by cimage.py)
export COCALC_SSH_PORT="2222"
export COCALC_PROJECT_ID=$PROJECT_ID
export COCALC_USERNAME="user"
export COCALC_LOCAL_HUB_PORT=6000
export COCALC_HTTP_PORT=6001
export COCALC_JUPYTER_LAB_PORT=6002
export DISPLAY=:0    # default Xpra server in the container will be here (if you start it).
export EXT="/ext"
export HOME=/home/user
export HOSTNAME=project-$1
export USER=user
export SMC=$HOME/.smc
export SMC_ROOT=/cocalc/src
export NODE_PATH=/cocalc/src:/cocalc/src/node_modules/smc-util:/cocalc/src/node_modules:/cocalc/src/smc-project/node_modules:/cocalc/src/smc-project/
export COCALC_USERNAME=user
# xrpa and ghc must come before /usr*
PATH_COCALC="/cocalc/bin:/cocalc/src/smc-project/bin:$HOME/bin:$HOME/.local/bin"
export PATH=$PATH_COCALC:$EXT/bin:/usr/lib/xpra:/opt/ghc/bin:/usr/local/bin:/usr/bin:/bin:$EXT/data/homer/bin:$EXT/data/weblogo:$EXT/intellij/idea/bin:$EXT/pycharm/pycharm/bin
export LC_ALL="C.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
export _JAVA_OPTIONS="-Djava.io.tmpdir=$HOME/tmp -Xms64m"
export NLTK_DATA="$EXT/data/nltk_data"
export ISOCHRONES="$EXT/data/isochrones"
export JUPYTER_PATH="$EXT/jupyter"
export JULIA_DEPOT_PATH="$HOME/.julia:$EXT/julia/depot/"
export ANACONDA3="$EXT/anaconda3"
export ANACONDA5="$EXT/anaconda5"
export NODE_ENV=production
export SCREENDIR="/tmp/screen"
export TERM="xterm-256color"
export MKL_THREADING_LAYER="GNU"    # mainly for theano, inside of pymc3

# X11: to run QT based apps like octave
export QT_QPA_PLATFORM=xcb

# X11: let XDG_RUNTIME_DIR point to some tmp directory and set perms right
export XDG_RUNTIME_DIR="/tmp/xdg-runtime-user"
mkdir -p "$XDG_RUNTIME_DIR"
chmod -R 700 "$XDG_RUNTIME_DIR"

echo $(date -Ins) "Configured whitelisted environment"
env | sort

# A global self-imposed limit number on open files to maybe prevent really
# dumb disasters...
export COCALC_ULIMIT_OPEN_FILES=10000
# And limit how many files they can open at once.
ulimit -n $COCALC_ULIMIT_OPEN_FILES

# Copy bashrc into place if there isn't one already
if [ ! -f $HOME/.bashrc ]; then
    cp /cocalc/init/bashrc $HOME/.bashrc
fi

# Linux bash_profile to bashrc if it doesn't exist.
if [ ! -f $HOME/.bash_profile ]; then
    rm -f $HOME/.bash_profile  # it may be a broken symlink!
    ln -s $HOME/.bashrc $HOME/.bash_profile
fi

# Make the ephemeral directory where status, temporary config, and log
# files about the local hub and other daemons are stored.
rm -rf "$SMC" && mkdir "$SMC"

bash /cocalc/kucalc-start-sshd.sh < /dev/null > /dev/stdout 2> /dev/stderr &
disown

if [[ -s "$HOME/project_init.sh" ]]; then
  bash "$HOME/project_init.sh" < /dev/null > /dev/stdout 2> /dev/stderr &
  disown
fi

# nvm: use node 10 + packages for the local hub (the setup prepends something to the PATH, that's all)
# and exec replaces the current process
# the local hub then cleans up some paths from the environment, such that subprocesses aren't affected
date -Ins
. /cocalc/nvm/nvm.sh --no-use
# 10 below is to select node version 10
nvm use --delete-prefix 10
date -Ins
exec node /cocalc/src/smc-project/local_hub.js --tcp_port 6000 --raw_port 6001


