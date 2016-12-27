FROM centos/ruby-22-centos7
MAINTAINER wei <weiwu1120@gmail.com>

ARG K8S_VERSION=v1.5.1
ARG K8S_ITERATION=1

ENV LANG en_US.UTF-8

USER root
RUN yum update -y
RUN yum install -y gcc make wget rpm-build ruby-devel
RUN gem install fpm

RUN wget https://dl.k8s.io/$K8S_VERSION/kubernetes-server-linux-amd64.tar.gz && \
    wget https://dl.k8s.io/$K8S_VERSION/kubernetes-client-linux-amd64.tar.gz && \
    wget https://dl.k8s.io/$K8S_VERSION/kubernetes-client-darwin-amd64.tar.gz && \
    mkdir kubernetes-$K8S_VERSION && \
    mkdir kubernetes-$K8S_VERSION-server && \
    tar zxvf kubernetes-client-linux-amd64.tar.gz -C kubernetes-$K8S_VERSION && \
    tar zxvf kubernetes-server-linux-amd64.tar.gz -C kubernetes-$K8S_VERSION-server && \
    rm kubernetes-server-linux-amd64.tar.gz && \
    rm kubernetes-client-linux-amd64.tar.gz && \
    cp kubernetes-$K8S_VERSION/kubernetes/client/bin/* /usr/bin/ && \
    cp kubernetes-$K8S_VERSION-server/kubernetes/server/bin/* /usr/bin/ && \
    chmod +x /usr/bin/kube*

RUN tar zcvf kubernetes-master-$K8S_VERSION.tar.gz -P \
    /usr/bin/kube-apiserver \
    /usr/bin/kube-controller-manager \
    /usr/bin/kube-scheduler && \
    fpm -s tar -t rpm -n kubernetes-master -v $K8S_VERSION --iteration $K8S_ITERATION -a noarch --verbose kubernetes-master-$K8S_VERSION.tar.gz

RUN tar zcvf kubernetes-node-$K8S_VERSION.tar.gz -P \
    /usr/bin/kubectl \
    /usr/bin/kubelet \
    /usr/bin/hyperkube \
    /usr/bin/kubefed && \
    fpm -s tar -t rpm -n kubernetes-node -v $K8S_VERSION --iteration $K8S_ITERATION -a noarch --verbose kubernetes-node-$K8S_VERSION.tar.gz
