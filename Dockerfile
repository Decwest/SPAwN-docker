FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel
RUN echo base image: ${base_image}

#######################################################################
##                            Speeding up                            ##
#######################################################################
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

#######################################################################
##                      install common packages                      ##
#######################################################################
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
   pkg-config \
   apt-utils \
   wget \
   curl \
   git \
   build-essential \ 
   net-tools \
   gedit \
   terminator \
   nautilus \
   software-properties-common \
   apt-transport-https \
   libopencv-dev \
   ffmpeg \
   x264 \
   libx264-dev \
   zip \
   unzip \
   usbutils \
   sudo \
   libusb-1.0-0-dev \
   dbus-x11

#######################################################################
##                           install font                            ##
#######################################################################
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections 
RUN apt-get update && apt-get install -y ttf-mscorefonts-installer \
    ttf-ubuntu-font-family \
    msttcorefonts -qq

#######################################################################
##                       install nvidia docker                       ##
#######################################################################
RUN add-apt-repository ppa:kisak/kisak-mesa -y
RUN apt-get install -y --no-install-recommends \
    libxau-dev \
    libxdmcp-dev \
    libxcb1-dev \
    libxext-dev \
    libx11-dev \
    mesa-utils \
    x11-apps

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# Required for non-glvnd setups.
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

#######################################################################
##                   install additional packages                     ##
#######################################################################
# WORKDIR  /
# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt update 

# anaconda
RUN set -x && \
    wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh && \
    bash Anaconda3-2022.10-Linux-x86_64.sh -b && \
    rm Anaconda3-2022.10-Linux-x86_64.sh

# path setting
ENV PATH $PATH:/root/anaconda3/bin

# Environment for Training and Evaluating
RUN conda create -n torch python=3.8
SHELL ["conda", "run", "-n", "torch", "/bin/bash", "-c"]
RUN conda install -c anaconda jupyter
RUN conda install pytorch torchvision torchaudio pytorch-cuda=11.6 -c pytorch -c nvidia
RUN conda install -c anaconda scikit-image 
RUN conda install -c conda-forge tqdm
RUN conda install -c conda-forge tensorboard
RUN conda install -c anaconda pandas
RUN conda install h5py

# Environment for Datasets Preparation
RUN conda create -n cv2 python=3.8
SHELL ["conda", "run", "-n", "cv2", "/bin/bash", "-c"]
RUN conda install -c menpo opencv
RUN conda install -c anaconda scikit-image 
RUN conda install -c conda-forge tqdm
RUN conda install -c conda-forge numpy

RUN conda init bash

CMD ["bash"]

#######################################################################
##                            delete cash                            ##
#######################################################################
RUN rm -rf /var/lib/apt/lists/*

RUN echo "export PS1='\[\e[1;31;40m\]SPAwN\[\e[0m\] \u:\w\$ '">> ~/.bashrc
RUN echo "source /entrypoint.sh">> ~/.bashrc

ARG workspace
WORKDIR ${workspace}
