# Nodejs forever!
#
# VERSION               0.0.1

FROM      ubuntu
MAINTAINER Michael Feher <personalpc@live.com>

RUN apt-get update && apt-get install -y wget

RUN echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list
RUN wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN apt-get update

RUN apt-get install -y npm nodejs git newrelic-sysmond
#RUN nrsysmond-config --set license_key=
RUN npm install forever -g


RUN git clone https://github.com/PhearZero/phear-engine.git
RUN cd phear-engine && npm install
