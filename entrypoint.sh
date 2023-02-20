#!/bin/bash

# verifica se a variável de ambiente BACKUP_ENABLED é definida como true

# exporta as variáveis de ambiente para serem usadas pelos comandos abaixo
export BACKUP_ENABLED="${BACKUP_ENABLED}"
export REMOTE_DB_HOST="${WORDPRESS_DB_HOST_REMOTO}"
export REMOTE_DB_USER="${WORDPRESS_DB_USER_REMOTO}"
export REMOTE_DB_PASSWORD="${WORDPRESS_DB_PASSWORD_REMOTO}"
export REMOTE_DB_NAME="${WORDPRESS_DB_NAME_REMOTO}"
export FTP_HOST="${FTP_HOST}"
export FTP_USER="${FTP_USER}"
export FTP_PASSWORD="${FTP_PASSWORD}"
export REMOTE_DIR_PATH="${REMOTE_DIR_PATH}"
export LOCAL_DIR_PATH="${LOCAL_DIR_PATH}"

if [ "$BACKUP_ENABLED" = "true" ]; then

  set -e

  if [ -f "/var/www/html/wp-config.php" ]; then
          echo "
              +-------------------------------------------+
              |    O WordPress está instalado....         |
              +-------------------------------------------+    
          ";
      else
              echo "
              +-------------------------------------------+
              |    Instalando WordPress....               |
              +-------------------------------------------+    
          ";

        curl -o /tmp/latest.zip https://wordpress.org/latest.zip
        unzip /tmp/latest.zip -d /var/www/html/
        mv /var/www/html/wordpress/* /var/www/html/
        rm -r /var/www/html/wordpress /var/www/html/wp-content 
        chown -R www-data:www-data /var/www/html/
        find /var/www/html/ -type d -exec chmod 755 {} \;
        find /var/www/html/ -type f -exec chmod 644 {} \;
        sed -e "s/database_name_here/wordpress/
            s/username_here/wordpress/
            s/password_here/wordpress/
            s/localhost/db/" /var/www/html/wp-config-sample.php > /var/www/html/wp-config.php

  fi

  echo "
      +-------------------------------------------+
      |    Iniciando Dump de banco remoto ...     |
      +-------------------------------------------+    
  ";

  # Export the database to a file
  mysqldump -h "$REMOTE_DB_HOST" -u "$REMOTE_DB_USER" -p"$REMOTE_DB_PASSWORD" -v "$REMOTE_DB_NAME" > /var/www/html/wordpress.sql
  if [ "$?" -eq 0 ]; then
    echo "Download do banco de dados remoto concluído com sucesso."
  else
    echo "Erro ao baixar o banco de dados remoto."
    exit 1
  fi

  echo "
      +-------------------------------------------+
      |    Importanto arquivo wordpress.sql    ...|
      +-------------------------------------------+    
  ";
  # Import the database from the file on the remote server
  mysql -hdb -uwordpress -pwordpress wordpress < /var/www/html/wordpress.sql
  if [ "$?" -eq 0 ]; then
    echo "Importação do banco de dados concluída com sucesso."
  else
    echo "Erro ao importar o banco de dados baixado."
    exit 1
  fi

  if [ ! -d "/var/www/html/wp-content" ]; then

    # copiar do servidor remoto para local, se quiser o oposto add -R
    lftp -e "set ssl:verify-certificate no; set xfer:use-temp-file false; set net:connection-limit 50; set net:socket-buffer 1048576; mirror --parallel=50 --verbose $REMOTE_DIR_PATH $LOCAL_DIR_PATH; exit" -u "$FTP_USER,$FTP_PASSWORD" $FTP_HOST
    
    if [ "$?" -eq 0 ]; then
      echo "Sincronização com o servidor remoto concluída com sucesso."
    else
      echo "Erro ao sincronizar arquivos com o servidor remoto."
      exit 1
    fi

  fi
  # Inicia o servidor Apache
  echo "
      +-------------------------------------------+
      |    Backup realizado com sucesso!          |
      +-------------------------------------------+    
  ";
fi