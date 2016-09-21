FROM centos:centos7

MAINTAINER Johann Bernez

# Adaptive Server will run under the sybase user. The same user and group must exists on this image
RUN yum -y update && \
    groupadd sybase && \
    useradd -g sybase -s /sbin/nologin sybase

