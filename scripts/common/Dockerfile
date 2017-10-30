FROM centos/ruby-22-centos7
MAINTAINER wei <weiwu1120@gmail.com>

ENV LANG en_US.UTF-8

USER root
RUN yum update -y && \
    yum install -y gcc make wget rpm-build ruby-devel && \
    rm -rf /var/cache/apt/* && \
    gem install fpm
