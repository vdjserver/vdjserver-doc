# Base Image
FROM debian:jessie

MAINTAINER VDJServer <vdjserver@utsouthwestern.edu>

# uncomment these if behind UTSW proxy
#ENV http_proxy 'http://proxy.swmed.edu:3128/'
#ENV https_proxy 'https://proxy.swmed.edu:3128/'
#ENV HTTP_PROXY 'http://proxy.swmed.edu:3128/'
#ENV HTTPS_PROXY 'https://proxy.swmed.edu:3128/'

# Install OS Dependencies
RUN apt-get update && apt-get install -y --fix-missing\
    build-essential \
    doxygen \
    git \
    graphviz \
    libbz2-dev \
    libxml2-dev \
    libxslt-dev \
    python \
    python-dev \
    python-sphinx \
    python-pip \
    vim \
    wget \
    zlib1g-dev

RUN pip install \
    biopython \
    lxml \
    numpy \
    reportlab

# Set boost config vars and files
ENV BOOST_VERSION 1.57.0
ENV BOOST_VERSION_LINK 1_57_0

# Install/bootstrap boost
RUN wget http://downloads.sourceforge.net/project/boost/boost/$BOOST_VERSION/boost_$BOOST_VERSION_LINK.tar.gz
RUN tar -xvzf boost_$BOOST_VERSION_LINK.tar.gz

COPY vdj_pipe/docker/boost/user-config.jam /root/
#RUN cd /boost_$BOOST_VERSION_LINK && ./bootstrap.sh --prefix=/usr/local
#RUN cd /boost_$BOOST_VERSION_LINK && ./b2 install
RUN cd /boost_$BOOST_VERSION_LINK/tools/build && ./bootstrap.sh
RUN cd /boost_$BOOST_VERSION_LINK/tools/build && ./b2 install --prefix=/usr/local

# Copy source
COPY . /vdjserver-doc-root
RUN mkdir /var/www && mkdir /var/www/html

###
### VDJPipe
###

# build docs
COPY vdj_pipe/docker/boost/boost-build.jam /vdjserver-doc-root/vdj_pipe
RUN cd /vdjserver-doc-root/vdj_pipe && b2 autodoc

# Put doc build artifact in accessible location
RUN mv /vdjserver-doc-root/vdj_pipe/out/html /var/www/html/vdjpipe
RUN cp /vdjserver-doc-root/vdj_pipe/doc/index.html /var/www/html/vdjpipe
RUN cp /vdjserver-doc-root/vdj_pipe/doc/config.html /var/www/html/vdjpipe

VOLUME ["/var/www/html/vdjpipe"]

###
### libVDJML
###

# Build docs
COPY vdjml/docker/boost/boost-build.jam /vdjserver-doc-root/vdjml
RUN cd /vdjserver-doc-root/vdjml && b2 docs

# Put doc build artifact in accessible location
RUN mv /vdjserver-doc-root/vdjml/out/binding/python/doc /var/www/html/vdjml
RUN cp -R /vdjserver-doc-root/vdjml/out/website/html/xsd_doc /var/www/html/vdjml/xsd_doc
RUN cp -R /vdjserver-doc-root/vdjml/out/binding/python/xsd /var/www/html/xsd

VOLUME ["/var/www/html/vdjml"]
VOLUME ["/var/www/html/xsd"]
