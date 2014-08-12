# Nodejs forever!
#
# VERSION               0.0.1

FROM      ubuntu
MAINTAINER Michael Feher <personalpc@live.com>

RUN apt-get update
RUN apt-get install -y npm nodejs git
RUN npm install forever -g

RUN git clone https://github.com/PhearZero/phear-engine.git
RUN cd phear-engine && npm install
