FROM nvcr.io/nvidia/clara-train-sdk:v4.0
ARG TF_SERVING_VERSION=0.0.0
ENV DEBIAN_FRONTEND noninteractive
ENV NB_UID 0
ENV PATH $HOME/.local/bin:$PATH

# Use bash instead of sh
SHELL ["/bin/bash", "-c"]
# Install Nodejs for jupyterlab-manager
RUN apt-get update && apt-get install -yq --no-install-recommends \
  apt-transport-https \
  build-essential \
  bzip2 \
  ca-certificates \
  curl \
  g++ \
  git \
  gnupg \
  graphviz \
  locales \
  lsb-release \
  openssh-client \
  sudo \
  unzip \
  vim \
  wget \
  zip \
  emacs \
  python3-pip \
  python3-dev \
  python3-setuptools \
  && apt-get clean && \
  rm -rf /var/lib/apt/lists/*


RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get update && apt-get install -yq --no-install-recommends \
  nodejs \
  && apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV DOCKER_CREDENTIAL_GCR_VERSION=1.4.3
RUN curl -LO https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${DOCKER_CREDENTIAL_GCR_VERSION}/docker-credential-gcr_linux_amd64-${DOCKER_CREDENTIAL_GCR_VERSION}.tar.gz && \
    tar -zxvf docker-credential-gcr_linux_amd64-${DOCKER_CREDENTIAL_GCR_VERSION}.tar.gz && \
    mv docker-credential-gcr /usr/local/bin/docker-credential-gcr && \
    rm docker-credential-gcr_linux_amd64-${DOCKER_CREDENTIAL_GCR_VERSION}.tar.gz && \
    chmod +x /usr/local/bin/docker-credential-gcr

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk kubectl


# Install base python3 packages
RUN python3 -m pip install --upgrade pip
#RUN apt-get update && apt-get upgrade -y 
RUN pip3 install --upgrade setuptools
RUN pip3 --no-cache-dir install \
    jupyter-console==6.0.0 \
    jupyterlab==2.2.0 \
    xgboost \
    kubeflow-fairing==1.0.0 --upgrade

RUN docker-credential-gcr configure-docker 

WORKDIR /
RUN pip3 uninstall -y jupyter-core && pip3 install jupyter-core   jupyter jupyterlab==2.2.0 
RUN pip3 uninstall -y bokeh
RUN pip3 install bokeh==1.4.0 numpy==1.16.4 jupyter  jupyter-core jupyter-tensorboard jupyterlab-nvdashboard==v0.3.1 --upgrade
RUN jupyter labextension install jupyterlab-nvdashboard@v0.3.1
RUN jupyter labextension install jupyterlab_tensorboard
#RUN jupyter labextension update --all


RUN pip3 install kfp jupyterhub sudospawner PyJWT oauthenticator --upgrade
RUN npm install -g configurable-http-proxy 

EXPOSE 8888
CMD ["jupyterhub-singleuser"]