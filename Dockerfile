FROM debian:latest
MAINTAINER Sebastian Dufner "dufners@informatik.uni-freiburg.de"

# Declare build parameters
ARG GIT=https://github.com/der-scheme/dmptool.git
ARG RELEASE=freiburg
#
ARG JOBS=4

# Image metadata
LABEL org.dmptool.git.remote=$GIT \
      org.dmptool.git.release=$RELEASE \
      description="" \
      version="0.1"

# Copy scripts and binaries
COPY dist/usr/sbin/* /usr/local/sbin/

# Copy static/initial configuration
COPY dist/etc/* /etc/

# Install packages
RUN apt-get update \
    && apt-get install -y \
        bash \
        build-essential \
        curl \
        git \
        libmysqlclient-dev \
        nginx \
        bundler \
        shibboleth-sp2-utils \
        supervisor \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Have root own the application directory, but enable www-data group everywhere
RUN mkdir -p          /var/www/app /var/www/.bundler \
    && chgrp www-data /var/www/app /var/www/.bundler \
    && chmod g+s,g-w  /var/www/app /var/www/.bundler

# Setup the web app's codebase
RUN git clone --branch $RELEASE --single-branch --depth 1 $GIT /var/www/app \
#
# www-data should be able to do everything with the tmp directory
    && mkdir /var/www/app/tmp \
    && chown www-data /var/www/app/tmp

# Install app dependencies
RUN cd /var/www/app \
    # tidy-ext doesn't compile with Debian's default MRI cflags.
    && bundle config build.tidy-ext --with-cflags="-O2 -pipe -march=native" \
    # Really install dependencies
    && bundle install --jobs $JOBS  --deployment --without development test

# I don't know why, but gems are installed with disregard towards our directory
# permissions. So we do the stuff from above again and remove it when the issue
# is fixed.
RUN chgrp www-data    /var/www/app /var/www/.bundler \
    && chmod g+s,g-w  /var/www/app /var/www/.bundler

EXPOSE 80 443

HEALTHCHECK --interval=1m --timeout=5s CMD /usr/local/sbin/healthcheck

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
