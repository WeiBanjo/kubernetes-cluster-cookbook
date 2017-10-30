FROM weiwu1120/rpm-builder:v0.1
MAINTAINER wei <weiwu1120@gmail.com>

ARG ETCD_VERSION=v3.2.9
ARG ETCD_ITERATION=1

RUN wget -q https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz && \
    tar zxf etcd-$ETCD_VERSION-linux-amd64.tar.gz --strip-components 1 -C /usr/bin/ && \
    rm -f etcd-$ETCD_VERSION-linux-amd64.tar.gz

RUN tar zcvf etcd-$ETCD_VERSION.tar.gz -P \
    /usr/bin/etcd \
    /usr/bin/etcdctl && \
    fpm -s tar -t rpm -n etcd -v $ETCD_VERSION --iteration $ETCD_ITERATION -a noarch --verbose etcd-$ETCD_VERSION.tar.gz
