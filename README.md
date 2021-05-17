Geckito Templates
=================

Geckito is an umbrella project to make (open)SUSE distributions ready
for Edge and IoT environments.

It consists of

 * The build tooling

 * The distribution in binary and source form

 * A collection of templates to demonstrate various forms of building,
   including image, container and package builds.
   These templates are provided here in this git repository

Most of them have some kind of image as result and build additional content.
This can be either via (rpm-)packages or during image builds.

Unlike other IoT projects Geckito allows to re-use as many pre-build
binaries as possible, while still allowing a rebuild of them. This 
allows faster turn-around times and also provides a perspective of
providing maintainable images in the long term.

The build can happen entirely local using the "pbuild" tool. Sources
and binaries can get exchanged with the Open Build Service (OBS), but
also via alternatives like git repositories.

Prerequisites
=============

The only critical prerequisite is the pbuild tool, which is part of the
SUSE's "build" package. The package is available from the
openSUSE:Tools project for almost every Linux distribution:

    https://download.opensuse.org/repositories/openSUSE:/Tools/

The pbuild tool is in active development and rapidly changing. Thus it
is probably better to directly clone it from git:

    git clone https://github.com/openSUSE/obs-build

pbuild can be executed directly from the directory containing the
sources. Do not forget to use an absolute path to the tool if you
run it from the obs-build git repository.

pbuild can be used to compile entire distributions. The configurations
from this collections make use of existing binaries to speed up the
build and providing supported content as much as possible.

References to external resources are defined via presets in the _pbuild files.

How To Use
==========

Change in any of the provided subdirectories and execute pbuild.
pbuild will list existing presets if no default is defined, otherwise
it will the build the image/packages.

It is recommended to use a specific vm-type:

 * kvm: recommended default
        - reproducible build
        - works as non-root user after granting chroot capability:
 ```shell
          # setcap CAP_SYS_CHROOT+ep /usr/bin/bsdtar
 ```

 * docker: works for simple packages
        - will fail for image builds
        - build results depending on kernel are not reproducible

 * chroot: not recommended, but current default :/
        - unsecure building when resources are not trusted
        - build results depending on kernel are not reproducible

Example:

 ```shell
 # cd minimal-os
 # pbuild --preset=openSUSE --vm-type=kvm
 ```

How to Build for foreign architectures using a system emulator
==============================================================

The simplest, but also slowest way is to use a system emulator. 

Ensure to have the right emulator installed. To build for ARM you need to


 ```shell
 # sudo zypper in qemu-arm
 ```

To run a build you need to use the "qemu" vm and to specify the target 
architecture. This works also as non-root if bsdtar has the chroot 
capability.

 ```shell
 # cd minimal-os
 # pbuild --vm-type=qemu --arch=aarch64
 ```

How to Build for foreign architectures using cross build
========================================================

Build configuration examples
============================

 minimal-os: small OS image which can be used on bare metal or VM emulators

 minimal-container: minimal container build

How to modify an example
========================

Compile during container build without packaging
================================================

1) use minimal-container example and modify the Dockerfile in Container directory

2) uncomment the "zypper in" line to install further needed tooling

3) add additional sources to compile to the Container directory

4) add compile commands

5) cleanup the container by deinstalling unwanted tooling

6) run pbuild in the minimal-container directory


Add a package to the project
============================

1) Pick any example project as base

2) create a subdirectory with package sources. Check https://build.opensuse.org if your package source
   may have been provided already by someone.

3) You may want to add the resulting binary packages to the image build description.

4) run pbuild in the project directory
   It will rebuild packages with changed sources and all packages which are affected by them.

