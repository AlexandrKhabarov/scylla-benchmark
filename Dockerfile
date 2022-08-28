ARG PYTHON_VERSION=2.7.18
FROM python:$PYTHON_VERSION

USER root

WORKDIR /root

RUN curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz
RUN tar xfvz ycsb-0.17.0.tar.gz
ENV YCSB_HOME=/root/ycsb-0.17.0
ENV PATH=$YCSB_HOME/bin:$PATH
