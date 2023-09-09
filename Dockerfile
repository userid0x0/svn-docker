# Alpine Linux with s6 service management
FROM crazymax/alpine-s6:3.18-3.1.5.0

# Install Apache2 and other stuff needed to access svn via WebDav
# Install svn
# Installing utilities for SVNADMIN frontend
# Enable global .htaccess (AllowOverride All)
# Enable LDAP for PHP
RUN apk add --no-cache apache2 apache2-ctl apache2-utils apache2-webdav mod_dav_svn &&\
	apk add --no-cache subversion subversion-libs subversion-tools &&\
	apk add --no-cache wget unzip &&\
	apk add --no-cache php82 php82-apache2 php82-session php82-json php82-ldap php82-xml &&\
	sed -i "\#Directory \"/var/www/localhost/htdocs#,\#Directory# s#AllowOverride None#AllowOverride All#g" /etc/apache2/httpd.conf &&\
	sed -i 's/;extension=ldap/extension=ldap/' /etc/php82/php.ini &&\
	mkdir -p /run/apache2/

# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)	
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

# Basicly from https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.zip
# + patches for PHP8
ADD svn-server/opt/default_data /opt/default_data
ADD iF.SVNAdmin /opt/svnadmin
RUN ln -s /opt/svnadmin /var/www/localhost/htdocs/svnadmin &&\
	rm -rf /opt/svnadmin/data

# Prepare WebSVN
ADD https://github.com/websvnphp/websvn/archive/refs/tags/2.8.1.zip /opt/websvn-2.8.1.zip
RUN unzip /opt/websvn-2.8.1.zip -d /opt &&\
	rm /opt/websvn-2.8.1.zip &&\
	mv /opt/websvn-2.8.1 /opt/websvn

# Prepare ReposStyle XSLT
ADD https://github.com/rburgoyne/repos-style/archive/refs/heads/master.zip /opt/repos-style.zip
RUN unzip /opt/repos-style.zip -d /opt \
	&& rm /opt/repos-style.zip \
	&& mv /opt/repos-style-master /opt/repos-style \
	&& sed -i 's#@@Repository@@#file:///data/repositories#g' /opt/repos-style/repos-web/open/log/index.php \
	&& sed -i '/isParent/ s/false/true/g' /opt/repos-style/repos-web/open/log/index.php \
	&& sed -i 's#--non-interactive#--non-interactive --config-dir /tmp/repos-style#g' /opt/repos-style/repos-web/open/log/index.php \
	&& sed -i "/<?php/a if (intval(getenv('SVN_SERVER_REPOS_STYLE_AUTH')) >= 2) die('Disabled for security reasons (Reason: svnauthz not supported by repos-style). Set SVN_SERVER_REPOS_STYLE_AUTH<2.');" /opt/repos-style/repos-web/open/log/index.php 

# Add oneshot scripts
ADD svn-server/etc/cont-init.d /etc/cont-init.d/

# Add services configurations
ADD svn-server/etc/services.d /etc/services.d/

# default environment paths
ENV SVN_SERVER_REPOSITORIES_URL=/svn \
	SVN_SERVER_REPOS_STYLE_AUTH=2 \
	WEBSVN_URL=/websvn \
	WEBSVN_AUTH=2

# Add WebDav configuration
ADD svn-server/etc/apache2/conf.d/dav_svn.conf /etc/apache2/conf.d/dav_svn.conf

# Expose ports for http
EXPOSE 80
