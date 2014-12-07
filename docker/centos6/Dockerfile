# Container for running rpmbuild on CentOS 6

FROM centos:centos6
MAINTAINER "Nick Townsend" <nick.townsend@mac.com>
ADD http://cpod.local/samples/c-pod.repo /etc/yum.repos.d/
RUN yum makecache && yum install -y \
    ack \
    bison \
    chef \
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
    rpm-build \
    ruby \
    tar \
    vim \
    zlib \
    zlib-devel
ADD http://cpod.local/samples/solo.rb /etc/chef/
ADD http://cpod.local/samples/cpod.json /etc/chef/
RUN chef-solo -o recipe[devuser::townsen]
RUN curl -o /usr/bin/gosu -sSL https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64 \
  && chmod +x /usr/bin/gosu
# The external path /vagrant is mapped from the host
# with owner and group id 1000 (vagrant) but there
# is no actual vagrant user or group. This causes
# permissions errors on rpmbuild.
#
RUN groupadd -g 1000 vagrant
RUN useradd -d /vagrant -g vagrant -u 1000 vagrant
RUN usermod -a -G vagrant townsen
ENV PATH ~/c-pod/bin:$PATH
USER townsen
WORKDIR /home/townsen/c-pod/rpmbuild/SPECS
CMD /bin/bash -l
