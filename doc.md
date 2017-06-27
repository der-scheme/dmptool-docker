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

These files might not literally exist, but be generated from a template file
(with extension _.tpl_) when needed.

#### etc/apache2/conf
  * **custom.conf** -- custom configuration that is included at the end
    end of the virtual host block. Add whatever additional functionality you
    need here.
  * **name.conf** -- controls server names and aliases
  * **ssl.conf** -- TLS configuration

#### etc/shibboleth

  * **attribute-map.xml** – nothing to be done, unless you
    need to define custom attributes.
  * **shibboleth2.xml** – the main Shibboleth configuration
    file.

#### etc/ssl/extern

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

#### etc/supervisor

  * **supervisor.conf** – configuration for the Supervisor process manager.

#### usr/sbin

  * **healthcheck** – used by Docker to determine if the container is functioning
    correctly.
  * **setup** – invoke to generate runtime configuration files.

### tools

  * **.loadconfig.sh** -- meta shell script that initializes the configuration
    environment
  * **generate-configs.sh** -- when invoked, substitutes variables in **.tpl**
    files and resaves them with their file extension removed

## Services

The image is running three services, these being Apache (webserver),
Puma (Rails application server) and Shibboleth SP (authentication provider), all
of them managed by the image's main process, Supervisor.

### Supervisor

Supervisor is the image's entry point and manages the three primary services, as
well as the Shibboleth FastCGI processes that Nginx utilizes to talk to the
Shibboleth SP.
Its configuration is baked into the image and thus is located beneath the
**dist** directory.

### Apache

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

#### Nginx

As of this writing, there doesn't exist a distribution of GNU/Linux that ships
with Shibboleth support for Nginx.

#### LDAP

LDAP was not included for two reasons:

 1. This project is focused on Shibboleth.
 2. If LDAP support was needed, the institution would already have their own
    LDAP running.

#### MYSQL (or other database systems)

Having the MYSQL service in another container or connecting to an existing
instance is better.

## Image building

Run ``docker-compose build dmptool``, no configuration required.

## Container configuration

 1. As an initial step, open the file **deploy.conf** with a text editor of your
    choice. Adjust the variables as you need them.

    _**Note** that although the variable definitions adhere to regular shell
    syntax, it is not evaluated as such. Comments are okay, but commands are not
    supported. For the exact semantics, understand the code in file
    **tools/.loadconfig.sh**._

 2. Run ``tools/generate-configs.sh``, which will evaluate all the config
    templates (**.tpl**).
 3. Configure the individual services, as described in the coming sections.

### Authentication (Shibboleth)

_This should be covered by the first steps._

### LDAP (not included)

Although provided by the DMPTool, the project specification explicitly did not
include LDAP support. However, enabling it should be as easy as mounting a valid
configuration in a Docker volume at **/var/www/app/config/ldap.yml**.

### Apache

_This should be covered by the first steps._

### Webapp (DMPTool)

_Most of the things needed should be covered by the first steps._

You may want to consider adjusting the DMPTool's frontend to your custom
flavour. To do this, edit the file **conf/var/www/app/config/layout.rb**. Feel
inspired by the file **config/layout.rb.template** from the DMPTool project.

## Deployment

 1. Copy the web server's SSL certificates to **conf/etc/ssl/extern**, or modify
    **docker-compose.yml**  such that it points to the correct paths.
 2. Follow the steps in sections _Image building_ (in case you're building
    yourself) and _Container configuration_.
 3. Setup database and assets: ``tools/setup.sh``
 4. Finally, invoke ``docker-compose run dmptool`` to deploy the container.

## Upgrading

Debian updates/upgrades or new releases of the DMPTool may want you upgrade your
installation. Here is how you do that.

 1. Git-pull the newest release of this project. If you got your image prebuilt
    from somewhere else, get the latest build from there instead and skip to
    step 3.
 2. Rebuild the image: ``docker-compose build --no-cache dmptool``
 3. Update the database: ``tools/setup.sh db migrate``
 4. Recompile the assets: ``tools/setup.sh assets precompile``
 5. Start the image: ``docker-compose start dmptool``
