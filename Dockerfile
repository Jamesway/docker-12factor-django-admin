FROM jamesway/python36-django:latest

MAINTAINER James <j@mesway.io>

COPY 12factor.sh /

ENTRYPOINT ["bash", "/12factor.sh"]
#CMD ["/bin/bash", "/12factor.sh"]
