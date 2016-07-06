FROM centos/ruby-22-centos7
MAINTAINER wei <weiwu1120@gmail.com>

ARG K8S_VERSION=v1.3.4
ENV K8S_VERSION ${K8S_VERSION}

ARG K8S_ITERATION=1
ENV K8S_ITERATION ${K8S_ITERATION}
ENV LANG en_US.UTF-8

USER root
RUN yum update -y
RUN yum install -y gcc make wget rpm-build
RUN yum install -y ruby-devel
RUN rm -rf /var/cache/apt/*
RUN gem install fpm

RUN wget https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/kubernetes.tar.gz
RUN mkdir kubernetes-$K8S_VERSION
RUN mkdir kubernetes-$K8S_VERSION-server

RUN tar zxvf kubernetes.tar.gz -C kubernetes-$K8S_VERSION
RUN tar zxvf kubernetes-$K8S_VERSION/kubernetes/server/kubernetes-server-linux-amd64.tar.gz -C kubernetes-$K8S_VERSION-server
RUN rm -f kubernetes-$K8S_VERSION-server/kubernetes/server/bin/*.tar
RUN rm -f kubernetes-$K8S_VERSION-server/kubernetes/server/bin/*.docker_tag
RUN rm -f kubernetes.tar.gz
RUN rm -rf kubernetes

RUN cp kubernetes-$K8S_VERSION-server/kubernetes/server/bin/* /usr/bin/

RUN tar zcvf kubernetes-master-$K8S_VERSION.tar.gz -P \
    /usr/bin/kube-apiserver

RUN fpm -s tar -t rpm -n kubernetes-master -v $K8S_VERSION --iteration $K8S_ITERATION -a noarch --verbose kubernetes-master-$K8S_VERSION.tar.gz

RUN tar zcvf kubernetes-node-$K8S_VERSION.tar.gz -P \
    /usr/bin/kubectl \
    /usr/bin/kubelet

RUN fpm -s tar -t rpm -n kubernetes-node -v $K8S_VERSION --iteration $K8S_ITERATION -a noarch --verbose kubernetes-node-$K8S_VERSION.tar.gz
