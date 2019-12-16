# Example FastCGI Web Application with Fano Web Framework

FastCGI Web application skeleton using Fano Framework, Pascal web application framework. This application is listen to Unix Domain Socket.


This project is generated using [Fano CLI](https://github.com/fanoframework/fano-cli)
command line tools to help scaffolding web application using Fano Framework.

## Requirement

- [Free Pascal](https://www.freepascal.org/) >= 3.0
- [libcurl development](https://curl.haxx.se/libcurl/)
- Web Server (Apache, nginx)
- [Fano Web Framework](https://github.com/fanoframework/fano)

## Installation

### Build

#### libcurl development package installation

Check if libcurl package for development is installed by running `curl-config`.

```
$ curl-config --version
```
If libcurl installed you will get something like `libcurl x.xx.x` where `x.xx.x` is version. For example `libcurl 7.47.0` otherwise you get

```
The program 'curl-config' can be found in the following packages:
 * libcurl4-gnutls-dev
 * libcurl4-nss-dev
 * libcurl4-openssl-dev
Try: sudo apt install <selected package>
```

In case libcurl not installed, run
```
$ sudo apt install libcurl4-gnutls-dev
```

### Free Pascal installation

Make sure [Free Pascal](https://www.freepascal.org/) is installed. Run

    $ fpc -i

If you see something like `Free Pascal Compiler version 3.0.4`,  you are good to go.

Clone this repository

    $ git clone git@github.com:fanofamework/fano-app.git --recursive

`--recursive` is needed so git also pull [Fano](https://github.com/fanoframework/fano) repository.

If you are missing `--recursive` when you clone, you may find that `vendor/fano` directory is empty. In this case run

    $ git submodule update --init

To update Fano to its latest commit, run

    $ git checkout master && git submodule foreach --recursive git pull origin master

Above command will checkout to `master` branch of this repository and pull latest update from `master` branch of [Fano](https://github.com/fanoframework/fano) repository.

Copy `*.cfg.sample` to `*.cfg`.
Make adjustment as you need in `build.cfg`, `build.prod.cfg`, `build.dev.cfg`
and run `build.sh` shell script (if you are on Windows, then `build.cmd`).

These `*.cfg` files contain some Free Pascal compiler switches that you can turn on/off to change how executable is compiled and generated. For complete
explanation on available compiler switches, consult Free Pascal documentation.

Also copy `src/config/config.json.sample` to `src/config/config.json` and edit
configuration as needed. For example, you may need to change `baseUrl` to match your own base url so JavaScript or CSS stylesheets point to correct URL.

    $ cp config/config.json.sample config/config.json
    $ cp build.prod.cfg.sample build.prod.cfg
    $ cp build.dev.cfg.sample build.dev.cfg
    $ cp build.cfg.sample build.cfg
    $ ./build.sh

`tools/config.setup.sh` shell script is provided to simplify copying those
configuration files. Following shell command is similar to command above.

    $ ./tools/config.setup.sh
    $ ./build.sh

By default, it will output binary executable in `public` directory.

### Build for different environment

To build for different environment, set `BUILD_TYPE` environment variable.

#### Build for production environment

    $ BUILD_TYPE=prod ./build.sh

Build process will use compiler configuration defined in `vendor/fano/fano.cfg`, `build.cfg` and `build.prod.cfg`. By default, `build.prod.cfg` contains some compiler switches that will aggressively optimize executable both in speed and size.

#### Build for development environment

    $ BUILD_TYPE=dev ./build.sh

Build process will use compiler configuration defined in `vendor/fano/fano.cfg`, `build.cfg` and `build.dev.cfg`.

If `BUILD_TYPE` environment variable is not set, production environment will be assumed.

## Change executable output directory

Compilation will output executable to directory defined in `EXEC_OUTPUT_DIR`
environment variable. By default is `public` directory.

    $ EXEC_OUTPUT_DIR=/path/to/public/dir ./build.sh

## Change executable name

Compilation will use executable filename as defined in `EXEC_OUTPUT_NAME`
environment variable. By default is `app.cgi` filename.

    $ EXEC_OUTPUT_NAME=index.cgi ./build.sh

## Run

Run example Fano FastCGI application

```
$ ./public/app.cgi
```

By default it will listen on Unix domain socket `/tmp/fano-fcgi-unix.sock` file.
You need to make sure `/tmp/fano-fcgi-unix.sock` permission is writeable
by web server.

### Run with a webserver

Setup a virtual host. Please consult documentation of web server you use.

#### Apache

You need to use Apache 2.4 and to have `mod_proxy_fcgi` installed and loaded. This module is Apache's built-in module, so it is very likely that you will have it with your Apache installation. You just need to make sure it is loaded. For example, on Debian,

```
$ sudo a2enmod proxy_fcgi
$ sudo systemctl restart apache2
```

Create virtual host config and add `ProxyPassMatch`, for example

```
<VirtualHost *:80>
     ServerName www.example.com
     DocumentRoot /home/example/public

     <Directory "/home/example/public">
         Options +ExecCGI
         AllowOverride FileInfo
         Require all granted
     </Directory>

    ProxyRequests Off
    ProxyPass /css !
    ProxyPass /images !
    ProxyPass /js !
    ProxyPassMatch ^/(.*)$ "unix:/tmp/fano-fcgi-unix.sock|fcgi://127.0.0.1"
</VirtualHost>
```
Last four line of virtual host configurations basically tell Apache to serve any
files inside `css`, `images`, `js` directly otherwise pass it to our application.

Hostname after `fcgi://` are ignored by `mod_proxy_fcgi`.

On Debian, save it to `/etc/apache2/sites-available` for example as `fano-fcgi-unix.conf`
Enable this site and restart Apache

```
$ sudo a2ensite fano-fcgi-unix.conf
$ sudo systemctl restart apache2
```

If Apache returns `HTTP 503 Service Unavailable` and you get following similar messages in error log

```
[Fri Jun 28 15:46:52.111034 2019] [proxy:error] [pid 18974] (13)Permission denied: AH02454: FCGI: attempt to connect to Unix domain socket /tmp/fano-fcgi-unix.sock (127.0.0.1) failed
```

then make sure that socket file is writeable by user where Apache runs.

If you get following message when running application,

```
ESocketError: Binding of socket failed: /tmp/fano-fcgi/fano-fcgi-unix.sock
```

Delete `/tmp/fano-fcgi/fano-fcgi-unix.sock` first then re-run application.

If you run Debian 9 based distribution, each user now has private /tmp directory, which may cause problem because Apache cannot find our socket file.

## Deployment

You need to deploy only executable binary and any supporting files such as HTML templates, images, css stylesheets, application config.
Any `pas` or `inc` files or shell scripts is not needed in deployment machine in order application to run.

So for this repository, you will need to copy `public`, `Templates`, `config`
and `storages` directories to your deployment machine. make sure that
`storages` directory is writable by web server.

## Known Issues

### Issue with GNU Linker

When running `build.sh` script, you may encounter following warning:

```
/usr/bin/ld: warning: public/link.res contains output sections; did you forget -T?
```

This is known issue between Free Pascal and GNU Linker. See
[FAQ: link.res syntax error, or "did you forget -T?"](https://www.freepascal.org/faq.var#unix-ld219)

However, this warning is minor and can be ignored. It does not affect output executable.

### Issue with unsynchronized compiled unit with unit source

Sometime Free Pascal can not compile your code because, for example, you deleted a
unit source code (.pas) but old generated unit (.ppu, .o, .a files) still there
or when you switch between git branches. Solution is to remove those files.

By default, generated compiled units are in `bin/unit` directory.
But do not delete `README.md` file inside this directory, as it is not being ignored by git.

```
$ rm bin/unit/*.ppu
$ rm bin/unit/*.o
$ rm bin/unit/*.rsj
$ rm bin/unit/*.a
```

Following shell command will remove all files inside `bin/unit` directory except
`README.md` file.

    $ find bin/unit ! -name 'README.md' -type f -exec rm -f {} +

`tools/clean.sh` script is provided to simplify this task.

### Windows user

Free Pascal supports Windows as target operating system, however, this repository is not yet tested on Windows. To target Windows, in `build.cfg` replace
compiler switch `-Tlinux` with `-Twin64` and uncomment line `#-WC` to
become `-WC`.

### Lazarus user

While you can use Lazarus IDE, it is not mandatory tool. Any text editor for code editing (Atom, Visual Studio Code, Sublime, Vim etc) should suffice.
