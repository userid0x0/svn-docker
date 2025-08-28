# Alpine Linux with s6 service management
FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# Install Apache2 and other stuff needed to access svn via WebDav
# Install svn
# Installing utilities for SVNADMIN frontend
# Enable global .htaccess (AllowOverride All)
# Enable LDAP for PHP
# Remove user apache/svn -> use user `abc`, group `abc` instead (created by linuxserver baseimage)
RUN apk add --no-cache apache2 apache2-ctl apache2-utils apache2-webdav mod_dav_svn \
	&& apk add --no-cache subversion subversion-libs subversion-tools \
	&& apk add --no-cache wget unzip \
	&& apk add --no-cache php83 php83-apache2 php83-session php83-json php83-ldap php83-xml \
	&& sed -i "\#Directory \"/var/www/localhost/htdocs#,\#Directory# s#AllowOverride None#AllowOverride All#g" /etc/apache2/httpd.conf \
	&& sed -i 's/;extension=ldap/extension=ldap/' /etc/php83/php.ini \
	&& deluser apache \
	&& deluser svn && delgroup svnusers \
	&& sed -i 's/^User.*/User abc/' /etc/apache2/httpd.conf \
	&& sed -i 's/^Group.*/Group abc/' /etc/apache2/httpd.conf

COPY root/ /

# Basicly from https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.zip
# + patches for PHP8
ADD --chown=abc:abc \
	https://github.com/mfreiholz/iF.SVNAdmin.git#63d85ca06a0315592a52321dc0783ed5c33fc5df \
	/opt/svnadmin
RUN ln -s /opt/svnadmin /var/www/localhost/htdocs/svnadmin \
	&& rm -rf /opt/svnadmin/data

# Prepare WebSVN
ADD --chown=abc:abc \
	https://github.com/websvnphp/websvn.git#2.8.4 \
	/opt/websvn

# Prepare ReposStyle XSLT
ADD --chown=abc:abc \
	https://github.com/rburgoyne/repos-style.git#0c891a168548bd83c17e94152ecca7c2a3d6c203 \
	/opt/repos-style
RUN sed -i 's#@@Repository@@#file:///config/repositories#g' /opt/repos-style/repos-web/open/log/index.php \
	&& sed -i '/isParent/ s/false/true/g' /opt/repos-style/repos-web/open/log/index.php \
	&& sed -i 's#--non-interactive#--non-interactive --config-dir /tmp/repos-style#g' /opt/repos-style/repos-web/open/log/index.php \
	&& sed -i "/<?php/a if (intval(getenv('SVN_SERVER_REPOS_STYLE_AUTH')) >= 2) die('Disabled for security reasons (Reason: svnauthz not supported by repos-style). Set SVN_SERVER_REPOS_STYLE_AUTH<2.');" /opt/repos-style/repos-web/open/log/index.php

# default environment paths
ENV SVN_SERVER_REPOSITORIES_URL=/svn \
	SVN_SERVER_REPOS_STYLE_AUTH=2 \
	WEBSVN_URL=/websvn \
	WEBSVN_AUTH=2 \
	S6_BEHAVIOUR_IF_STAGE2_FAILS=2

EXPOSE 80

