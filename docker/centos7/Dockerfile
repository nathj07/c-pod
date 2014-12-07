# Container for running rpmbuild on CentOS 7

FROM centos:centos7
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
    ruby-devel \
    rubygems \
    rubygems-devel \
    rubygem-minitest \
    rubygem-rake \
    tar \
    vim \
    zlib \
    zlib-devel
ADD http://cpod.local/samples/solo.rb /etc/chef/
ADD http://cpod.local/samples/cpod.json /etc/chef/
RUN curl -o /usr/bin/gosu -sSL https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64 \
  && chmod +x /usr/bin/gosu
# The external path /vagrant is mapped from the host
# with owner and group id 1000 (vagrant) but there
# is no actual vagrant user or group. This causes
# permissions errors on rpmbuild.
#
RUN groupadd -g 1000 rpmbuilder
RUN useradd -g rpmbuilder -u 1000 rpmbuilder
COPY vimrc /home/rpmbuilder/.vimrc
COPY rpmmacros /home/rpmbuilder/.rpmmacros
COPY bash_profile /home/rpmbuilder/.bash_profile
RUN  chown rpmbuilder.rpmbuilder /home/rpmbuilder/.{vimrc,rpmmacros,bash_profile}
WORKDIR /root
CMD /bin/bash -l

# To get this to execute as a specific user consider putting an ENTRYPOINT
# that runs Chef on container initialization, not during image creation
# Running Chef during container initialization on CentOS 7 is problematic,
# it fails complaining about the node name not being found. To overcome this
# either define the hostname (which seems odd during a build) or add the 
# line 'node_name' to solo.rb. This behaviour true of both 11.16 and 12.0 Chef. 
