FROM weiwu1120/rpm-builder:v0.1
MAINTAINER wei <weiwu1120@gmail.com>

ARG FLANNEL_VERSION=v0.9.0
ARG FLANNEL_PACKAGE_VERSION=0.9.0
ARG FLANNEL_ITERATION=2
ARG FLANNEL_ARCH=el7

RUN wget -q https://github.com/coreos/flannel/releases/download/$FLANNEL_VERSION/flannel-$FLANNEL_VERSION-linux-amd64.tar.gz && \
    tar zxf flannel-$FLANNEL_VERSION-linux-amd64.tar.gz -C /usr/bin/ && \
    rm -f flannel-$FLANNEL_VERSION-linux-amd64.tar.gz

RUN tar zcvf flannel-$FLANNEL_VERSION.tar.gz -P /usr/bin/flanneld && \
    fpm -s tar -t rpm -n flannel -v $FLANNEL_PACKAGE_VERSION --iteration $FLANNEL_ITERATION -a $FLANNEL_ARCH --verbose flannel-$FLANNEL_VERSION.tar.gz
