# Alpine Linux with s6 service management
FROM crazymax/alpine-s6:edge

	# Install Apache2 and other stuff needed to access svn via WebDav
	# Install svn
	# Installing utilities for SVNADMIN frontend
RUN apk add --no-cache apache2 apache2-ctl apache2-utils apache2-webdav mod_dav_svn &&\
	apk add --no-cache subversion subversion-tools &&\
	apk add --no-cache wget unzip &&\
	apk add --no-cache php82 php82-apache2 php82-session php82-json php82-ldap php82-xml &&\
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

# 
ADD https://github.com/rburgoyne/repos-style/archive/refs/heads/master.zip /opt/repos-style.zip
RUN unzip /opt/repos-style.zip -d /opt &&\
	rm /opt/repos-style.zip &&\
	mv /opt/repos-style-master /opt/repos-style &&\
	ln -s /opt/repos-style/repos-web /var/www/localhost/htdocs/repos-web

# Add oneshot scripts
ADD svn-server/etc/cont-init.d /etc/cont-init.d/

# Add services configurations
ADD svn-server/etc/services.d /etc/services.d/

# default environment paths
ENV SVN_SERVER_REPOSITORIES_URL=/svn \
	WEBSVN_URL=/websvn \
	WEBSVN_AUTH=2

# Add WebDav configuration
ADD svn-server/etc/apache2/conf.d/dav_svn.conf /etc/apache2/conf.d/dav_svn.conf

# Set HOME in non /root folder
# ENV HOME /home

# USER apache

# Expose ports for http and custom protocol access
EXPOSE 80
