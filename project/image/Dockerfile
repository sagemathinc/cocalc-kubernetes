FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 LC_ALL=C.UTF-8

LABEL maintainer="SageMath, Inc. <office@sagemath.com>"

# tini: https://github.com/krallin/tini
# This is also included in Docker itself via the `--init` flag
COPY tini /tini

# So we can source (http://goo.gl/oBPi5G), which we will do in build.sh.
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install prerequisites ubuntu packages for building the project nodejs server code.
RUN \
     chmod +x /tini \
  && apt-get update && apt-get upgrade -y \
  && apt-get install -y gnupg2 curl wget python3 python python-pip git make g++ sudo dpkg-dev \
                        flex bison libreadline-dev libz-dev libssl-dev libpq5 libpq-dev vim telnet build-essential \
  && apt-get clean && apt-get -y autoremove

# Get the source code of cocalc, putting it at /cocalc
RUN umask 022 && git clone https://github.com/sagemathinc/cocalc.git

# We install our own Node 10, which is independent of the node setup of the host image
# (i.e. we can change the software stack at will without interfering with running the project)
RUN \
     umask 022 \
  && cd /cocalc \
  && mkdir /cocalc/nvm \
  && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | NVM_DIR=/cocalc/nvm bash \
  && source /cocalc/nvm/nvm.sh \
  && nvm install --latest-npm --no-progress 10 \
  && npm install -g coffeescript

# Get our custom build script.
COPY k8s_build.py /cocalc/k8s_build.py

# Which branch to checkout and build.
ARG branch=master

# Run the build script once, so subsequent builds will be fast.
RUN umask 022 && source /cocalc/nvm/nvm.sh && /cocalc/k8s_build.py

# Delete some stupid big stuff from the /cocalc build; this won't be needed
# if we better refactor the smc-webapp code.  For now, we just do it.
RUN \
     cd /cocalc/src/smc-webapp/node_modules \
  && rm -rf three jquery-ui nyc react-draggable mathjax

# This is a multistage build:
FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 LC_ALL=C.UTF-8
LABEL maintainer="SageMath, Inc. <office@sagemath.com>"

# For now, install enough deps to at least run the project's server,
# build and run Sage, and have a little fun.
RUN \
     apt-get update \
  && apt-get install -y gnupg2 openssh-server vim apt-utils wget curl \
  && apt-get clean && apt-get -y autoremove

# Copy the build files over, which were built or updated above.
COPY --from=0 /cocalc/nvm /cocalc/nvm
COPY --from=0 /cocalc/src /cocalc/src
COPY --from=0 /cocalc/bin /cocalc/bin
COPY --from=0 /cocalc/lib /cocalc/lib
COPY --from=0 /tini /cocalc/bin/tini

# Create the project user's home account and home directory.
# TODO deal with .bashrc (/home/user is a volume)
COPY init /cocalc/init/

# This is our own all-in-one config file. Should be readable by the "user"
COPY kucalc-start-sshd.sh /cocalc/kucalc-start-sshd.sh

COPY smc-sage-server /cocalc/bin/smc-sage-server

# We do not use uid around 1000 since that's what the privileged
# accounts on the host are likely to use.
# ATTN some changes here (like, the user id number) should correspond to smc-build:smc-ansible/compute-k8s.yaml
RUN \
     umask 022 \
  && mkdir /home/user \
  && chown 2001:2001 -R /home/user \
  && /usr/sbin/groupadd --gid=2001 -o user \
  && /usr/sbin/useradd  --home-dir=/home/user --gid=2001 --uid=2001 --shell=/bin/bash user \
  && mkdir -p /var/run/sshd \
  && mkdir -p /usr/local/lib/python2.7/dist-packages/ \
  && echo "/cocalc/lib/python2.7/site-packages" > /usr/local/lib/python2.7/dist-packages/cocalc.pth \
  && chmod ugo=r /usr/local/lib/python2.7/dist-packages/cocalc.pth

# Switch to being that user.
USER user

WORKDIR /home/user

EXPOSE 2222 6000 6001

ENTRYPOINT ["/cocalc/bin/tini", "--"]
CMD ["sh", "-c", "env -i /cocalc/init/init.sh $COCALC_PROJECT_ID $KUCALC_IMAGE_NAME"]

