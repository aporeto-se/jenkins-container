FROM jenkins/jenkins:lts
WORKDIR /
MAINTAINER jodyscott

USER root

RUN apt update
RUN apt install -y jq

ADD cache/awscliv2.zip /tmp/awscliv2.zip
RUN unzip -d /tmp /tmp/awscliv2.zip
RUN /tmp/aws/install -b /usr/bin
RUN rm -rf /tmp/aws*

ADD cache/kops /usr/bin
RUN chmod +x /usr/bin/kops

ADD cache/kubectl /usr/bin
RUN chmod +x /usr/bin/kubectl
