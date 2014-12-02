# Container for running rpmbuild on things...

FROM centos:centos6
MAINTAINER "Nick Townsend" <nick.townsend@mac.com>
ADD http://cpod.local/samples/c-pod.repo /etc/yum.repos.d/
RUN yum makecache && yum install -y \
    bison \
    flex \
    gcc \
    gcc-c++ \
    git \
    libtool-ltdl \
    libtool-ltdl-devel \
    libyaml-devel \
    make \
    openssl-devel \
    patch \
    readline \
    readline-devel \
    rpmbuild \
    tar \
    vim \
    zlib \
    zlib-devel
ADD http://cpod.local/samples/solo.rb /etc/chef/
RUN chef-solo -o recipe[devuser::townsen]
