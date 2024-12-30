
# Apache docker templates

- [Apache docker templates](#apache-docker-templates)
- [No cache](#no-cache)
  - [No cache example](#no-cache-example)
- [Custom 404 page](#custom-404-page)
  - [Custom 404 page example](#custom-404-page-example)
- [Mixed root folder](#mixed-root-folder)
- [Example mixed root folder](#example-mixed-root-folder)

# No cache

Add

```Apache
Header set Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
Header set Pragma "no-cache"
Header set Expires "Wed, 11 Jan 1984 05:00:00 GMT"
```

to `apache2.conf` in `<Directory /var/www/>`

## No cache example

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

# Custom 404 page

Add `ErrorDocument 404 /404.php` to the `000-default.conf` file

## Custom 404 page example

```Apache
<VirtualHost *:80>
    ErrorDocument 404 /404.php
[...]
```

# Mixed root folder

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

# Example mixed root folder

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
