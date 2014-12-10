# Docker

This is a general introduction to Docker as used in a C-Pod. Docker is a client-server application.
In the C-Pod usage model the C-Pod host machine is configured as a Docker server, and is accessed
from a remote client typically running Mac OS X.

## Installation

When building a C-Pod using Vagrant, Docker server is automatically installed.

### MacOS X

As Docker containers are currently based on Linux LXC you can only install the client. However you
can setup a remote TCP connection to a Docker server.

The command `brew install docker` will give you the latest version, however the current CentOS 7
package is older (version 1.2.0) and you get a client/server protocol version mismatch. To get the
older version:

```bash
brew unlink docker
brew install https://raw.githubusercontent.com/Homebrew/homebrew/3412dc98f63d99f34a7d4d0a851d0aa93e6ccdfa/Library/Formula/docker.rb
```
Use the `brew switch` command to toggle between them.

You should also setup command completion. First install `brew install bash-completion` then add the following to your `~/.bash_profile`

```bash
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
```

To run a Docker *server* on MacOSX you can use [Boot2docker](boot2docker.io) to install a Virtual
Box based setup, but it appears to be slower than VMware Fusion. Testing an install of `gem gollum`
took about one third less time using VMWare Fusion 7.01 versus Virtual Box (12m vs 8m). The
Vagrantfile in this repository creates a custom Ubuntu installation using VMWare Fusion.

### Vagrant

Vagrant allows the use of Docker both as a provider and a provisioner. Use the latter to install,
configure and run Docker from the `Vagrantfile`:

```ruby
  config.vm.provision :docker do |d|
    d.version = :latest
    d.images  = ['centos:centos6']
    d.build_image "/vagrant", args: "-t 'townsen/rpmbuild'"
    d.run "townsen/rpmbuild",
          cmd: "bash -l",
          args: "-i -t -h rpmbuilder -v '/vagrant:/home/townsen/c-pod'"
  end
```

### CentOS

```bash
yum install docker
systemctl enable docker
systemctl start docker
```
See `/etc/sysconfig/docker` for daemon options.

### Ubuntu

TLDR:

    curl -sSL https://get.docker.com/ubuntu/ | sudo sh

The full details are in [this document](http://docs.docker.com/installation/ubuntulinux/). Note that
if you do `apt-get install docker.io` you get the older version. The actual packages are
`lxc-docker-1.3.2`.

Daemon options are in `/etc/defaults/docker`

## Configuration

### Remote Access

Normally the Docker server listens on a Unix socket, access to which is restricted by membership of
the 'docker' group. In order to build and deploy images from your Mac you need to add a TCP
connection socket. It is conventional to use port 2375 for un-encrypted, and port 2376 for encrypted
communication with the daemon. Add the following to the Docker daemon options:

```bash
--host=tcp://0.0.0.0:2375 --host=unix:///var/run/docker.sock
```

Then to access from a remote client:

```bash
docker -H tcp://localhost:2375 run -i -t ubuntu:14.10 /bin/bash
```
Or export `DOCKER_HOST=tcp://localhost:2375` to void passing `-H` on every command.

If this fails check that the host machine allows the port to pass through any firewall.

### Image Storage

See the [summary of command line options](http://docs.docker.com/reference/commandline/cli/)

By default, Docker uses a loopback-mounted sparse file in `/var/lib/docker` for storing images.  The
loopback makes it slower, and there are some restrictive defaults, such as 100GB max storage. See
`/etc/sysconfig/docker-storage` if you want to configure an LV for storage.

The Ubuntu Vagrant Box used in the Vagrantfile build is configured with a 20GB limit on space.

## Concepts

Docker has [very good documentation](https://docs.docker.com/userguide/) but here is a quick synopsis:

### Terminology

Docker has, from the bottom up the following concepts:

* _Containers_ which are the things that execute and are instances of images.
* _Images_ which are snapshots of an environment,
* _Repository_ which is a scheme for naming an image,
* _Registries_ which can contain many repositories,

Repositories are simply structured names for an image and take the form _repository:tag_. The tag is
optional and if omitted defaults to `:latest`. The repository name can take a prefix, separated from
the name by a forward-slash.  The prefix identifies a user ID on DockerHub, e.g.: `townsen/centos6`.
Some repository names exist in the DockerHub global namespace - for example `ubuntu`. 

Images are identified by a 256 bit hash (the ID), and _optionally_ a repository name. Note that an
image that has been 'named' is sometimes referred to as a 'repository' which can confuse you as a
repository also refers to the collected set of images sharing the top level namespace.

Containers are also identified by a 256 bit hash (the ID) and _always_ have a name. This name isn't
the repository name. If you don't assign one at run time (with the `--name` option) it is auto
generated in the form 'adjective_famousperson' e.g. _happy_einstein_

### Lifecycle

A summary of the container lifecycle:

* Images may be pulled from a remote repository using `docker pull`, although this will be done automatically when using `docker run`

* Each time you use the `docker build` command an image is created, though it may not be named. Use `docker images` to see a list of these. Use `docker rmi` to delete them.

* The `docker tag` command actually pushes a named commit to a remote repository.

* Each time you use the `docker run` command you supply an image name or ID and it creates a container. The container is always given a generated catchy-name, though you can specify your own.

* As the container executes the changes it makes to the original image are persisted in the container. You can see the size of these by using `docker ps -s` and the details using `docker diff`. The changes can be committed to form a new image (and optionally named at the same time) using the `docker commit` command.

* When operating interactively you can detach from a running container using the magic key sequence `<ctrl-P><ctrl-Q>`. Use `docker attach` with the container ID (hash or name) to reconnect.

* When the primary process in the container terminates, the container exits.

* After a container exits it is _not_ deleted, and you can still access it by name or container ID.

    * View with `docker ps -a`
    * Delete with `docker rm` (see below)
    * Copy files using `docker cp`
    * Restart using `docker start <name>` followed by `docker attach <name>`. The command that the container was last running is restarted. If you want to specify a new command to execute then you have to create a new image (see next).
    * Create a new repository/image with `docker commit`. This you can run with a new command.
* Discarded containers tend to proliferate, after failed builds the intermediate containers are kept to allow rapid rebuilding of images. You can fairly safely remove failed containers using:

    ```bash
    docker rm $(docker ps -q -a --filter exited=1) # remove all that exited failed
    ```

    Provided that you have committed the ones you really want to images, you can use something stronger like:

    ```bash
    docker rm $(docker ps -q -a --filter status=exited) # remove all that have exited
    ```

## Quickstart

A few simple things to try. Remember to install the correct Docker Client and set DOCKER_HOST to point to the server.

### Install the CentOS Images

This step is not strictly necessary as images will automatically be downloaded when required.

```bash
docker pull centos
docker images centos
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
centos              centos5             192178b11d36        2 weeks ago         466.9 MB
centos              centos6             70441cac1ed5        2 weeks ago         215.8 MB
centos              centos7             ae0c2d0bdc10        2 weeks ago         224 MB
centos              latest              ae0c2d0bdc10        2 weeks ago         224 MB
```

Note that it is part of the Docker layering philosophy that these images are
very stripped down. You will need to install all the packages required for your
use case into layers on top of these starting points.

### Run CentOS 7

```bash
docker run -i -t centos:centos7 /bin/bash
```

### Run Ubuntu on CentOS

Install the Ubuntu 14.04 container and run a shell:

```bash
docker pull ubuntu:14.04
docker run -i -t ubuntu:14.04 /bin/bash
lsb_release -a
exit
```

## Neat Tricks

* You can attach to the same container more than once and thus have shared command line sessions with co-workers!

## Networking

Docker is designed to isolate containers as much as possible:

* Network addresses are assigned on a 'private' interface `docker0` which each container bridges to. You can bridge this.
* Docker uses random IP address assignment inside a specified or defaulted RFC1918 space.
* When specifying `-h` on the `docker run` that assigns the _container_ host name. This goes into `/etc/hosts` on the container, but *not* on the host machine.
* When linking a container the linked containers are visible in ENV vars and also in the linkers `/etc/hosts`. This means that `.local` names not necessary. Regular DNS lookups work.

## Processes

Although the container is designed to run a single process, there are ways around that:

* You can run multiple processes using [Supervisor](http://supervisord.org)
* By default the main process's stdout is deemed the 'log' and can be viewed with `docker log`
