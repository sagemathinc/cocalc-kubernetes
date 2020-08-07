FROM ubuntu:18.04

MAINTAINER William Stein <wstein@sagemath.com>

USER root

# We assume typescript code is not invalid when building this to save a lot of time.
ENV TS_TRANSPILE_ONLY true
ENV DEBIAN_FRONTEND noninteractive
ENV COCALC_KUBERNETES yes

# So we can source (see http://goo.gl/oBPi5G), e.g., smc-env below.
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install the deps for building and using cocalc's server.
RUN \
     umask 022 && apt-get update \
  && apt-get install -y wget git make g++ dpkg-dev flex curl wget \
     bison libreadline-dev libz-dev libssl-dev \
      python3-yaml  python-pip python3-pip \
     libpq5 libpq-dev postgresql-client postgresql postgresql-contrib \
     haproxy \
     nginx \
     rsync \
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -y nodejs \
  && npm install coffeescript -g

# Installing Kubectl
RUN \
  apt-get update && \
  apt-get install -y gnupg2 curl apt-transport-https && \
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list && \
  apt-get update && apt-get install -y kubectl

# useful utilities, for admin:
RUN apt-get install -y vim tmux telnet

# for nfs server functionality
RUN apt-get install -y nfs-kernel-server

# Routine build updates will starts here (or above), since RANDOM will be set to
# something random (by our build script). TODO -- re-enable when stable
# ARG RANDOM=

# Commit to checkout and build.
ARG branch=HEAD

# Pull latest source code for CoCalc and checkout requested branch (or HEAD)
RUN \
     umask 022 && git clone https://github.com/sagemathinc/cocalc.git \
  && cd /cocalc && git pull && git fetch origin && git checkout ${branch:-HEAD}

# Build and install all deps
# CRITICAL to install first web, then compute, since compute precompiles all the .js
# for fast startup, but unfortunately doing so breaks ./install.py all --web, since
# the .js files laying around somehow mess up cjsx loading.
RUN umask 022 && cd /cocalc/src && . ./smc-env && ./install.py all --web
RUN umask 022 && cd /cocalc/src && . ./smc-env && ./install.py all --compute
RUN rm -rf /root/.npm /root/.node-gyp/

### Configuration
COPY nginx.conf /etc/nginx/sites-available/default
COPY haproxy.conf /etc/haproxy/haproxy.cfg
COPY run.py /root/run.py
COPY bashrc /root/.bashrc
COPY exports /etc/exports
COPY start-nfs.sh /root/start-nfs.sh

RUN umask 022 && apt-get install -y ssh sudo

# User that the database runs under.  (TODO: why?)
RUN    adduser --quiet --shell /bin/bash --gecos "Sage user,101,," --disabled-password sage \
    && chown -R sage:sage /home/sage/

CMD /root/run.py

EXPOSE 80 443
