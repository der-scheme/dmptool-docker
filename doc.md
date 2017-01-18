# Documentation
This document aims to provide a quick overview over the dmptool-docker docker
image and how to configure it.

## Directory Layout
The project is split into several directories, mainly **conf** and **dist**,
which serve as filesystem roots for configuration options made by the admin and
by the image maintainer, respectively.

### conf
Hosts files for runtime configuration. Paths shall be mounted at the filesystem
root.

#### etc/nginx
  * **custom.conf** – custom configuration for Nginx that is included at the end
    end of the virtual host block. Add whatever additional functionality you
    need here.
  * **ssl.conf** – TLS configuration for Nginx. Uncomment and modify available
    directives as needed.

#### etc/ssl
Put your SSL certificates here.

#### var/www/app/config
  * **app_config.yml** – strange config file.
  * **database.yml** – specify database connection details.
  * **layout.rb** – define custom website header and footer.
  * **shibboleth.yml** – specify shibboleth connection details.

### dist
Hosts files for static configuration baked into the image. Paths are copied to
the filesystem root, except for everything below **usr**, which is copied to
**/usr/local**.

#### etc/nginx
  * **conf.d/dmptool.conf** – configuration for the Nginx virtual host.

#### etc/supervisor
  * **supervisor.conf** – configuration for the Supervisor process manager.

#### usr/sbin
  * **healthcheck** – used by Docker to determine if the container is functioning
    correctly.
  * **setup** – invoke to generate runtime configuration files.

### tools
_Nothing here, yet._

## Services
The image is running three services, these being Nginx (webserver), Puma (Rails
application server) and Shibboleth SP (authentication provider), all of them
managed by the image's main process, Supervisor.

### Supervisor
Supervisor is the image's entry point and manages the three primary services, as
well as the Shibboleth FastCGI processes that Nginx utilizes to talk to the
Shibboleth SP.
Its configuration is baked into the image and thus is located beneath the
**dist** directory.

### Nginx
The image's web server, providing an interface to Puma and Shibboleth SP.
Its in-image configuration includes everything required to run the DMPTool with
a Shibboleth SP. If additional functionality is required, check ssl.conf for
HTTPS, and custom.conf for anything else.

### Puma
The Rails application server, running the DMPTool.
Currently, no configuration is exposed at running time.

### Shibboleth Service Provider
The authentication provider.

### Not included
A word on services that you might expect, but that were not included in the
image.

#### Apache
Nginx is the web server of choice, thus Apache would be redundant.

#### LDAP
LDAP was not included for two reasons:

 1. This project is focused on Shibboleth.
 2. If LDAP support was needed, the institution would already have their own
    LDAP running.

#### MYSQL (and other database systems)
Having the MYSQL service in another container or connecting to an existing
instance is better.

## DMPTool configuration

### Authentication (Shibboleth)
Configure Shibboleth by correctly modifying all tags prefixed by
```<!-- CHANGEME -->```.

### LDAP (not included)
Although provided by the DMPTool, the project specification explicitly did not
include LDAP support. However, enabling it should be as easy as mounting a valid
configuration in a Docker volume at **/var/www/app/config/ldap.yml**.

