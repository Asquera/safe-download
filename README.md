# safe-download

A sinatra-based download server that can stand in as a small CDN server.

## What is it good for?

It allows you to offload large downloads to a standalone download server while still maintaining access control. This frees your application server for application tasks and scales better.

## How does it work?

The application uses a shared secret to generate an HMAC-Signed URL that's valid for a specified period of time. The service verifies that the signature is correct and then hands of the download to nginx. The signing mechanism is described in https://github.com/Asquera/warden-hmac-authentication/blob/master/README.md

### What languages are supported

The download service is tested on ruby 1.9.3 but should work flawlessly anywhere where sinatra and the warden-hmac-authentication gem work. Client libraries are available for ruby, php and java. The protocol is pretty straightforward to implement, so client libs for other languages shouldn't be a problem.

* Java client: https://github.com/justahero/hmac-java
* PHP client: https://github.com/Asquera/warden-hmac-authentication/tree/master/clients/php

## Ok, ok, show me how to run it

### Prerequisites

* ruby 1.9.3
* nginx

To install the download-server clone the repository, create an appropriate config file and deploy it to a ruby webserver of your choice. We have good experience with a setup that uses nginx to proxy to a thin webserver, but passenger should work perfectly as well. I'd recommend not using unicorn or a process-based webserver.

Install and configure Nginx. The sample configuration assumes that the download-server is run as standalone app.


````
server {
  listen 192.168.33.10:80;
  server_name     safe-download.dev;
  access_log      /var/log/nginx/safe-download.dev.access_log;
  error_log       /var/log/nginx/safe-download.dev.error_log info;

  root            /var/www;

  location /files {
     root /var/www;
     internal;
  }

  location / {
      proxy_pass  http://127.0.0.1:18001;
        proxy_redirect off;

        proxy_set_header Host            $host;
        proxy_set_header X-Real-IP       $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        client_max_body_size             10m;
        client_body_buffer_size          128k;

        proxy_connect_timeout            90;
        proxy_send_timeout               90;
        proxy_read_timeout               90;

        proxy_buffer_size                4k;
        proxy_buffers                    4 32k;
        proxy_busy_buffers_size          64k;
        proxy_temp_file_write_size       64k;
   }
}
````

This assumes that all files are located in /var/www/files and accessed via http://safe-download.dev/downloads/<path/to/file.txt>.

## Looks nice, but I don't want to set up my own server just to test this

There's a vagrant VM hidden in the 'development-box' branch. It contains the full setup so you can hack and test.
