# Docker Volume Plugin for CephFS

This work is based on [https://github.com/vieux/docker-volume-sshfs](https://github.com/vieux/docker-volume-sshfs) which is programmed by [Victor Vieux](https://github.com/vieux) and released under MIT license! Many thanks for your clean code!

Documentation is work in progress...

# Docker Volume Plugin for CephFS

There are quite a few plugins already which can be used to mount a CephFS into a Docker volume. But either they are old (> 2 years) or the code isn't really structured. Therefore I decide to write a new one based on the SSHFS plugin mentioned above because we need it at work and ... just for fun. :-)

# Prerequisites

This plugin just executes the `mount` command to mount a CephFS filesystem and therefore expects that the Ceph Kernel module is installed and running in your Docker host.

Furthermore an already existing CephFS filesystem in the Ceph cluster ist required.

All Docker Volume Plugin parameters are mandatory:
~~~yaml
    driver_opts:
      name: nginx
      path: /container/nginx
      secret: AQDEJ41bnfunnyUl8ArFKDYYv12TRoWJuyg==
      monitors: ceph-mon1:6789,ceph-mon1.147:6789
~~~


# Installation

First, install the plugin:
~~~bash
> docker plugin install n0r1skcom/docker-volume-cephfs
Plugin "n0r1skcom/docker-volume-cephfs" is requesting the following privileges:
 - network: [host]
 - mount: [/var/lib/docker/plugins/]
 - capabilities: [CAP_SYS_ADMIN]
Do you grant the above permissions? [y/N] y
latest: Pulling from n0r1skcom/docker-volume-cephfs
3a2b9eff8a35: Download complete 
Digest: sha256:008800aebadf9ae3fcb15e9d4bd9a695a8835e814c8d333f9d07b7ca85686046
Status: Downloaded newer image for n0r1skcom/docker-volume-cephfs:latest
Installed plugin n0r1skcom/docker-volume-cephfs
~~~

After this, check if the plugin is loaded and enabled:
~~~bash
> docker plugin ls
ID                  NAME                                    DESCRIPTION                ENABLED
8e9cdeec3312        n0r1skcom/docker-volume-cephfs:latest   cephFS plugin for Docker   true
~~~

# Docker manual usage

Create a Docker volume:
~~~bash
> docker volume create -d n0r1skcom/docker-volume-cephfs -o name=nginx -o path=/container/nginx -o secret=AQDEJ41bn7B8funnyl8ArFKDYYv12TRoWJuyg== -o monitors=ceph-mon1:6789,cephmon2:6789 cephfs_data
~~~

Check if the volume is created:
~~~bash
> docker volume ls
DRIVER                                  VOLUME NAME
n0r1skcom/docker-volume-cephfs:latest   cephfs_data
~~~

Start a container with the volume as mount and list the content of the mounted CephFS:
~~~
> docker run --rm -v cephfs_data:/data alpine ls /data
lala
test
~~~

In the mounts, the ceph mount is now visible:
~~~bash
> mount | grep ceph
ceph-mon1:6789,ceph-mon1:6789:/container/nginx on /var/lib/docker/plugins/8e9cdeec33127a692cf573cf64104ba426427dc3c31b078ddb30e329ecb84efc/propagated-mount/e5402392-0017-42e1-8fec-0295304dbefb-a9c25880eb33c5c98d81a9e14859657b type ceph (rw,relatime,name=nginx,secret=<hidden>,acl,wsize=16777216)
~~~

# Docker Swarm usage

Docker Swarm file to show the Docker Volumne plugin usage:
~~~yaml
version: "3"

services:

  app:
    image: nginx
    deploy:
      restart_policy:
        condition: any
      mode: replicated
      replicas: 2
    volumes:
      - data:/data

volumes:
  data:
    driver: n0r1skcom/docker-volume-cephfs
    driver_opts:
      name: nginx
      path: /container/nginx
      secret: AQDEJ41bnfunnyUl8ArFKDYYv12TRoWJuyg==
      monitors: ceph-mon1:6789,ceph-mon1.147:6789

~~~

Deploy the stack:
~~~bash
> docker stack deploy -c  test-swarm.yml test
Creating network test_default
Creating service test_app
~~~

List the volumes:
~~~
> docker volume ls
n0r1skcom/docker-volume-cephfs:latest   test_data
~~~

Check if the data is in one of the replicas:
~~~
docker exec -ti test_app.1.p7yrkjsnfaykpw0q9fuszmplc ls /data
lala  test
~~~

# LICENSE

MIT
