#!/bin/bash
source /.env

MYSQL_READY() {
   mysqladmin ping --host=${DOCKER_MARIADB_CONTAINER_NAME} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} > /dev/null 2>&1
}


# Ejecuta tareas de inicialización ambiente
if ! [ -f /tmp/is_initialized ]; then

    tfile=`mktemp`

    # Creo usuario de trabajo con shell zsh, e intalo adicionalmente "oh my zsh"
    useradd -ms /bin/zsh ${LINUX_USR}
    echo "${LINUX_USR}:${LINUX_USR_PWD}"|chpasswd
    usermod -aG sudo ${LINUX_USR}
    echo "${LINUX_USR} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    mkdir /home/${LINUX_USR}/.ssh
    chown -R ${LINUX_USR}:${LINUX_USR} /home/${LINUX_USR}/.ssh
    echo "\nsshd: ALL" >> /etc/hosts.allow;

    # Configuro accesos para usuario root
    echo "root:${LINUX_USR_PWD}"|chpasswd
    sed -i -- "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
    

    # Añadimos el usuario de LINUX_USR al grupo www-data, y aplicamos permisos generales
    usermod -a -G www-data ${LINUX_USR}
    chgrp -R www-data /var/www
    chmod -R g+w /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod ug+rw {} \;


    # Instalación de Oh my zsh para el usuario de LINUX_USR.
    su - ${LINUX_USR} -c "wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true"

    cp /.env /home/${LINUX_USR}/.env
    cat >> /home/${LINUX_USR}/.zshrc <<EOF
source /home/${LINUX_USR}/.env
EOF

    chown -R ${LINUX_USR}:${LINUX_USR} /home/${LINUX_USR}/.profile    

    sed -i -- "s/export APACHE_RUN_USER/export APACHE_RUN_USER=${LINUX_USR}/g" /etc/apache2/envvars
    sed -i -- "s/export APACHE_RUN_GROUP/export APACHE_RUN_GROUP=${LINUX_USR}/g" /etc/apache2/envvars

    echo "Genera bandera de inicialización para que no vuelva a ejecutarse ..."
    touch /tmp/is_initialized

    echo "Finalmente elimina el archivo temporal utilizado ..."
    if [ -f ${tfile} ]; then
      rm ${tfile};
    fi
    

fi

echo "Listo ;)"

service apache2 restart
service ssh restart


tail -f /dev/null




