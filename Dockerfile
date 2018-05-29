
FROM wordpress:4.7.2-apache

ARG LINUX_USR
ARG LINUX_USR_PWD

MAINTAINER Juan Pablo Sepúlveda "jpsepulvedaf@gmail.com"

# Update aptitude with new repo
RUN apt-get update



# Habilita el volumen para poder registrar los logs de errores de apache2
VOLUME /etc/apache2/apache_log


	# Ahora procedemos a instalar herramientas básicas:
RUN set -ex; \
	\
	apt install -y \
	    ssh \
		nmap \
		traceroute \
		tcpdump \
		chkrootkit \
		telnet \
		htop \
		jnettop \
		dnsutils \
		git \
		lsof \
		ntpdate \
		vim \
		nano \
    ;


# Instalamos el paquete "bzip2" para poder comprimir y descomprimir archivos
RUN set -ex; \
    \
    apt update; \
	apt install -y \
    bzip2 \
    ;

# Instalamos Zsh y otros ...
RUN set -ex; \
    \
    apt update; \
	apt install -y \
	sudo \
    zsh \
    wget \
    fonts-powerline \
    mysql-client \
    ;

# Instalación de Oh my zsh para el usuario root
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN chsh -s /bin/zsh root

# Para reducir el tamaño, borramos la caché de paquetes apt y la lista de paquetes descargada
RUN apt-get clean && rm -rf /var/lib/apt/lists/*;

RUN echo "America/Santiago" > /etc/timezone; 

COPY .env /.env

COPY start.sh /start.sh

RUN chmod 775 /start.sh

WORKDIR /var/www

ENV LINUX_USR ${LINUX_USR}
ENV LINUX_USR_PWD ${LINUX_USR_PWD}

EXPOSE 22
EXPOSE 80

# Mailcatcher
EXPOSE 1080
EXPOSE 1025

USER root


