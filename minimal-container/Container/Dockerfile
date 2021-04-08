# Defines the tag for OBS and build script builds:
#!BuildTag: my_container
# use the repositories defined in base image and the local build packages by pbuild
#!UseOBSRepositories
FROM opensuse/leap:15.3

#USER wwwrun
#WORKDIR /srv/www

# Define your additional repositories here
#RUN zypper ar http://download.opensuse.org/repositories/openSUSE:Tools/openSUSE_15.2 openSUSE:Tools

# Put additional files into container
#ADD . README.MY_APPLIANCE
#COPY MY.FILE /opt/my_space

# replace release package
RUN zypper remove -R -y product:Leap-15.3-1.x86_64
RUN zypper install -y geckito-release

# Install further packages using zypper
#RUN zypper install -y osc build

# This command will get executed on container start by default
#CMD /usr/sbin/httpd2-prefork

