FROM wordpress

# Instala o lftp e o mysql-client
RUN apt-get update && \
    apt-get install -y unzip default-mysql-client lftp  

# Copia o arquivo de entrada para o contêiner
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Torna o arquivo de entrada executável
RUN chmod +x /usr/local/bin/entrypoint.sh

# Define o arquivo de entrada como o entrypoint
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

