# Profiler-VM
## Requirements
* vagrant >= 1.7.0
* puppet >= 3.2.0
* hiera >= 1.3.0

## Basics
* OS: CentOS 6.6
* IP: 192.168.33.230
* Domain: profiler.move-elevator.dev

## Contents
* [Apache](http://httpd.apache.org/) 2.2.15
* [PHP](http://php.net/) 5.6 latest with xdebug and xhprof
* [xhgui](https://github.com/perftools/xhgui) 

## Optional
### Change bash to oh-my-zsh shell
* as root and or vagrant user

```
chsh -s /bin/zsh
```

### Change PHP ini values
* add needed parts [here](files/99-overwrites.ini)

## Troubleshooting
### httpd does not start 
If httpd doesnt start, and you something like this in the log:

```
[notice] SELinux policy enabled; httpd running as context unconfined_u:system_r:httpd_t:s0
[notice] suEXEC mechanism enabled (wrapper: /usr/sbin/suexec)
[notice] Digest: generating secret for digest authentication ...
[notice] Digest: done
[emerg] (17)File exists: mod_fcgid: Can't create shared memory for size 1200712 bytes
```

Try disabling SELinux:

```
$ setenforce 0
```