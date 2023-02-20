Entrypoint de um container Docker Compose para WordPress

Este repositório contém um script em bash que é usado como entrypoint de um container Docker Compose para WordPress. Ele é responsável por executar algumas tarefas importantes no início da execução do container, como:

    Verificar se a variável de ambiente BACKUP_ENABLED está definida como true;
    Exportar as variáveis de ambiente necessárias para serem usadas pelos comandos abaixo;
    Verificar se o WordPress está instalado e, se não estiver, realizar a instalação;
    Realizar o dump de um banco de dados remoto e importá-lo no banco de dados local;
    Sincronizar arquivos com um servidor remoto (se necessário);
    Iniciar o servidor Apache.

Variáveis de ambiente

As seguintes variáveis de ambiente são usadas pelo script:

    BACKUP_ENABLED: Define se o backup está habilitado (true/false);
    WORDPRESS_DB_HOST_REMOTO: Host do banco de dados remoto;
    WORDPRESS_DB_USER_REMOTO: Usuário do banco de dados remoto;
    WORDPRESS_DB_PASSWORD_REMOTO: Senha do banco de dados remoto;
    WORDPRESS_DB_NAME_REMOTO: Nome do banco de dados remoto;
    FTP_HOST: Host do servidor FTP;
    FTP_USER: Usuário do servidor FTP;
    FTP_PASSWORD: Senha do servidor FTP;
    REMOTE_DIR_PATH: Caminho remoto da pasta /wp-content, somente esta pasta será necessario, não será necessario copiar todos os diretorios do servidor remoto;
    LOCAL_DIR_PATH: caminha raiz do site ex: /var/www/html.

Como usar

Para caso voce precise somente criar um wordpress, altere a variavel BACKUP_ENABLED para false, e execute docker-compose up, que será criado uma instancia do wordpress e banco, acessando a porta configurada no docker-compose.yml para acessar o site.
Caso voce precise criar um ambiente a sincronizado com um servidor remoto que esteja em wordpress, informe as variaveis acima no docker-compose.yml como se pede, e execute docker-compose up --build, apos este processo vc vai executar a seguinte linha de comando, docker exec nome_container ./entrypoint.sh, assim iniciara a instalacao e a sincronizaçao de arquivos e banco.


Contribuindo

Se você encontrar algum problema com o script ou quiser adicionar novos recursos, sinta-se à vontade para enviar uma solicitação de pull.
