FROM debian:latest
MAINTAINER Sebastian Dufner "dufners@informatik.uni-freiburg.de"

# Declare build parameters
ARG APP_DIR=/var/www/app
ARG GIT=https://github.com/der-scheme/dmptool.git
ARG RELEASE=freiburg
ARG RAILS_ENV=production
#
ARG JOBS=4

# Environments
ENV APP_DIR=${APP_DIR}
ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_ROOT=/var/www/app

# Image metadata
LABEL org.dmptool.git.remote=$GIT \
      org.dmptool.git.release=$RELEASE \
      description="" \
      version="0.1"

# Copy scripts and binaries
COPY dist/usr/sbin /usr/local/sbin/

# Install packages
RUN install-packages --apt \
        apache2 \
        bash \
        build-essential \
        curl \
        git \
        libapache2-mod-shib2 \
        default-libmysqlclient-dev \
        bundler \
        supervisor \
        zlib1g-dev

# Have root own the application directory, but enable www-data group everywhere
RUN mkdir -p          ${RAILS_ROOT} ${RAILS_ROOT}/../.bundler \
    && chgrp www-data ${RAILS_ROOT} ${RAILS_ROOT}/../.bundler \
    && chmod g+s,g-w  ${RAILS_ROOT} ${RAILS_ROOT}/../.bundler

# Setup the web app's codebase
RUN git clone --branch $RELEASE --single-branch --depth 1 $GIT ${RAILS_ROOT} \
#
# www-data should be able to do everything with the tmp directory
    && mkdir ${RAILS_ROOT}/tmp \
    && chown www-data ${RAILS_ROOT}/tmp

# Install app dependencies
RUN cd ${RAILS_ROOT} \
    # tidy-ext doesn't compile with Debian's default MRI cflags.
    && bundle config build.tidy-ext --with-cflags="-O2 -pipe -march=native" \
    # Really install dependencies
    && bundle install --jobs $JOBS  --deployment --without development test

# I don't know why, but gems are installed with disregard towards our directory
# permissions. So we do the stuff from above again and remove it when the issue
# is fixed.
RUN chgrp -R www-data    ${RAILS_ROOT}/vendor/bundle \
    && chmod -R g+s,g-w  ${RAILS_ROOT}/vendor/bundle

# Copy static/initial configuration
COPY dist/etc /etc/

# Setup apache
RUN a2enmod proxy_http \
    && a2enmod shib2 \
    && a2ensite dmptool \
    && a2ensite dmptool_ssl

EXPOSE 80 443

HEALTHCHECK --interval=1m --timeout=5s CMD /usr/local/sbin/healthcheck

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
