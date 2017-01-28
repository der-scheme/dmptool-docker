FROM debian:jessie
MAINTAINER Sebastian Dufner "dufners@informatik.uni-freiburg.de"

# Declare build parameters
ARG GIT=https://github.com/der-scheme/dmptool.git
ARG RELEASE=freiburg
#
ARG HTTP_PORT=80
ARG HTTPS_PORT=443

# Image metadata
LABEL org.dmptool.git.remote=$GIT \
      org.dmptool.git.release=$RELEASE \
      server.http.port=$HTTP_PORT \
      server.https.port=$HTTPS_PORT \
      description="" \
      version="0.1"

# Copy scripts and binaries
COPY dist/usr/sbin/* /usr/local/sbin/

# Copy static/initial configuration
COPY dist/etc/* /etc/

# Have root own the application directory, but enable www-data group everywhere
RUN mkdir -p /var/www/app && chgrp www-data /var/www/app && chmod g+s /var/www/app
#
# Setup the web app's codebase
ADD $GIT#$RELEASE /var/www/app
#
# www-data should be able to do everything with the tmp directory
RUN chown -R www-data /var/www/app/tmp

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
        bash \
        build-essential \
        curl \
        nginx \
        ruby2.1-dev \
        shibboleth-sp2-utils \
        supervisor \
    && rm -rf /var/lib/apt/lists/* \
    && cd /var/www/app && bundle install --without development test

EXPOSE $HTTP_PORT $HTTPS_PORT

HEALTHCHECK --interval=1m --timeout=5s CMD /usr/local/sbin/healthcheck

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisor.conf"]
