
# Apache docker templates

## Table of contents

- [Apache docker templates](#apache-docker-templates)
  - [Table of contents](#table-of-contents)
  - [No cache](#no-cache)
    - [No cache example](#no-cache-example)
  - [Custom 404 page](#custom-404-page)
    - [Custom 404 page example](#custom-404-page-example)
  - [Mixed root folder](#mixed-root-folder)
    - [Example mixed root folder](#example-mixed-root-folder)
  - [Internal only page](#internal-only-page)
  - [Server only page](#server-only-page)
  - [HTTP to HTTPS redirect](#http-to-https-redirect)
  - [HTTPS](#https)
  - [Install PHP modules via Composer](#install-php-modules-via-composer)

---

## No cache

Add

```Apache
Header set Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
Header set Pragma "no-cache"
Header set Expires "Wed, 11 Jan 1984 05:00:00 GMT"
```

to `apache2.conf` in `<Directory /var/www/>`

### No cache example

```Apache
[...]
<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted

    Header set Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
    Header set Pragma "no-cache"
    Header set Expires "Wed, 11 Jan 1984 05:00:00 GMT"
</Directory>
[...]
```

---

## Custom 404 page

Add `ErrorDocument 404 /404.php` to `000-default.conf`

### Custom 404 page example

```Apache
<VirtualHost *:80>
    ErrorDocument 404 /404.php
[...]
```

---

## Mixed root folder

By having two directiories to serve files from, show the files in the same path for the client side \
Example: there are two directories with files to serve, res1 and res2, with this file contents of both directories got shown under / like if they all are in the same directory \
Add

```Apache
# Use mod_rewrite to combine the contents
RewriteEngine On
RewriteCond %{DOCUMENT_ROOT}/res1%{REQUEST_URI} -f [OR]
RewriteCond %{DOCUMENT_ROOT}/res1%{REQUEST_URI} -d
RewriteRule ^(.*)$ /res1/$1 [L]

# If the file does not exist in res1, look in res2
RewriteCond %{DOCUMENT_ROOT}/res2%{REQUEST_URI} -f [OR]
RewriteCond %{DOCUMENT_ROOT}/res2%{REQUEST_URI} -d
RewriteRule ^(.*)$ /res2/$1 [L]
```

to the `000-default.conf` file in `<Directory /var/www/html>`

### Example mixed root folder

```Apache
[...]
<Directory /var/www/html>
  Options FollowSymLinks
  AllowOverride All
  Require all granted

  # Use mod_rewrite to combine the contents
  RewriteEngine On
  RewriteCond %{DOCUMENT_ROOT}/res1%{REQUEST_URI} -f [OR]
  RewriteCond %{DOCUMENT_ROOT}/res1%{REQUEST_URI} -d
  RewriteRule ^(.*)$ /res1/$1 [L]

  # If the file does not exist in res1, look in res2
  RewriteCond %{DOCUMENT_ROOT}/res2%{REQUEST_URI} -f [OR]
  RewriteCond %{DOCUMENT_ROOT}/res2%{REQUEST_URI} -d
  RewriteRule ^(.*)$ /res2/$1 [L]
</Directory>
[...]
```

---

## Internal only page

The files under this directory can be opened only by 127.0.0.1, any other client gets a 403 \
Add

```Apache
<Location /internal>
  Require all denied
  Require ip 127.0.0.1
</Location>
```

to the `apache2.conf` file and replace `/internal` with the name of the directory

---

## Server only page

The files under this directory can be opened only by the server itself and nobody else, even 127.0.0.1 \
Add

```Apache
<Location /internal>
  Require all denied
</Location>
```

to the `apache2.conf` file and replace `/internal` with the name of the directory

---

## HTTP to HTTPS redirect

Redirect every HTTP request to the HTTPS port

```Apache
# Automatic HTTP redirect to HTTPS
<VirtualHost *:80>
    DocumentRoot /var/www/html

    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=302,L]

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

---

## HTTPS

Enable HTTPS support

```Apache
[...]
<VirtualHost *:443>
  DocumentRoot /var/www/html

  # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
  # error, crit, alert, emerg.
  # It is also possible to configure the loglevel for particular
  # modules, e.g.
  #LogLevel info ssl:warn

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  # For most configuration files from conf-available/, which are
  # enabled or disabled at a global level, it is possible to
  # include a line for only one particular virtual host. For example the
  # following line enables the CGI configuration for this host only
  # after it has been globally disabled with "a2disconf".
  #Include conf-available/serve-cgi-bin.conf

  #   SSL Engine Switch:
  #   Enable/Disable SSL for this virtual host.
  SSLEngine on

  #   A self-signed (snakeoil) certificate can be created by installing
  #   the ssl-cert package. See
  #   /usr/share/doc/apache2/README.Debian.gz for more info.
  #   If both key and certificate are stored in the same file, only the
  #   SSLCertificateFile directive is needed.
  SSLCertificateFile      /etc/ssl/certs/server-certs/server.crt
  SSLCertificateKeyFile   /etc/ssl/certs/server-certs/server.key

  #   Server Certificate Chain:
  #   Point SSLCertificateChainFile at a file containing the
  #   concatenation of PEM encoded CA certificates which form the
  #   certificate chain for the server certificate. Alternatively
  #   the referenced file can be the same as SSLCertificateFile
  #   when the CA certificates are directly appended to the server
  #   certificate for convinience.
  #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

  #   Certificate Authority (CA):
  #   Set the CA certificate verification path where to find CA
  #   certificates for client authentication or alternatively one
  #   huge file containing all of them (file must be PEM encoded)
  #   Note: Inside SSLCACertificatePath you need hash symlinks
  #   to point to the certificate files. Use the provided
  #   Makefile to update the hash symlinks after changes.
  #SSLCACertificatePath /etc/ssl/certs/
  #SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt

  #   Certificate Revocation Lists (CRL):
  #   Set the CA revocation path where to find CA CRLs for client
  #   authentication or alternatively one huge file containing all
  #   of them (file must be PEM encoded)
  #   Note: Inside SSLCARevocationPath you need hash symlinks
  #   to point to the certificate files. Use the provided
  #   Makefile to update the hash symlinks after changes.
  #SSLCARevocationPath /etc/apache2/ssl.crl/
  #SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl

  #   Client Authentication (Type):
  #   Client certificate verification type and depth.  Types are
  #   none, optional, require and optional_no_ca.  Depth is a
  #   number which specifies how deeply to verify the certificate
  #   issuer chain before deciding the certificate is not valid.
  #SSLVerifyClient require
  #SSLVerifyDepth  10

  #   SSL Engine Options:
  #   Set various options for the SSL engine.
  #   o FakeBasicAuth:
  #    Translate the client X.509 into a Basic Authorisation.  This means that
  #    the standard Auth/DBMAuth methods can be used for access control.  The
  #    user name is the `one line' version of the client's X.509 certificate.
  #    Note that no password is obtained from the user. Every entry in the user
  #    file needs this password: `xxj31ZMTZzkVA'.
  #   o ExportCertData:
  #    This exports two additional environment variables: SSL_CLIENT_CERT and
  #    SSL_SERVER_CERT. These contain the PEM-encoded certificates of the
  #    server (always existing) and the client (only existing when client
  #    authentication is used). This can be used to import the certificates
  #    into CGI scripts.
  #   o StdEnvVars:
  #    This exports the standard SSL/TLS related `SSL_*' environment variables.
  #    Per default this exportation is switched off for performance reasons,
  #    because the extraction step is an expensive operation and is usually
  #    useless for serving static content. So one usually enables the
  #    exportation for CGI and SSI requests only.
  #   o OptRenegotiate:
  #    This enables optimized SSL connection renegotiation handling when SSL
  #    directives are used in per-directory context.
  #SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire
  <FilesMatch "\.(?:cgi|shtml|phtml|php)$">
    SSLOptions +StdEnvVars
  </FilesMatch>
  <Directory /usr/lib/cgi-bin>
    SSLOptions +StdEnvVars
  </Directory>

  #   SSL Protocol Adjustments:
  #   The safe and default but still SSL/TLS standard compliant shutdown
  #   approach is that mod_ssl sends the close notify alert but doesn't wait for
  #   the close notify alert from client. When you need a different shutdown
  #   approach you can use one of the following variables:
  #   o ssl-unclean-shutdown:
  #    This forces an unclean shutdown when the connection is closed, i.e. no
  #    SSL close notify alert is send or allowed to received.  This violates
  #    the SSL/TLS standard but is needed for some brain-dead browsers. Use
  #    this when you receive I/O errors because of the standard approach where
  #    mod_ssl sends the close notify alert.
  #   o ssl-accurate-shutdown:
  #    This forces an accurate shutdown when the connection is closed, i.e. a
  #    SSL close notify alert is send and mod_ssl waits for the close notify
  #    alert of the client. This is 100% SSL/TLS standard compliant, but in
  #    practice often causes hanging connections with brain-dead browsers. Use
  #    this only for browsers where you know that their SSL implementation
  #    works correctly.
  #   Notice: Most problems of broken clients are also related to the HTTP
  #   keep-alive facility, so you usually additionally want to disable
  #   keep-alive for those clients, too. Use variable "nokeepalive" for this.
  #   Similarly, one has to force some clients to use HTTP/1.0 to workaround
  #   their broken HTTP/1.1 implementation. Use variables "downgrade-1.0" and
  #   "force-response-1.0" for this.
  # BrowserMatch "MSIE [2-6]" \
  # nokeepalive ssl-unclean-shutdown \
  # downgrade-1.0 force-response-1.0

</VirtualHost>
[...]
```

In `000-default.conf` \
Make sure to have placed the server's public and private keys in `/etc/ssl/certs/server-certs` or having mounted the directory via docker-compose

```docker
volumes:
  # Mounts are in read only to prevent changes by the container (eg if any vulnerability is exploited allowing the container to write to the host)
  - ./cert:/etc/ssl/certs/server-certs:ro # Directory with server's SSL certificate
```

Self signed certificate can be generated with `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cert/server.key -out cert/server.crt`

---

## Install PHP modules via Composer

Put in Dockerfile

```docker
RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer
RUN cd / && composer require {php_module_name} && composer clearcache
```

Make sure to replace `{php_module_name}` with the name of the PHP module (eg. `google/apiclient`)

To call the library:

```php
require realpath('/vendor/autoload.php');
```
