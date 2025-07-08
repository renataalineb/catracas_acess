FROM mcr.microsoft.com/mssql/server:2019-latest

ENV ACCEPT_EULA=Y \
    SA_PASSWORD=Thunderc@ts123 \
    MSSQL_PID=Developer \
    MSSQL_AGENT_ENABLED=true

USER root

# Corrige permissões
RUN mkdir -p /var/opt/mssql/data && \
    chown -R mssql /var/opt/mssql

# Instala ferramentas úteis
RUN apt-get update && \
    apt-get install -y curl gnupg apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools unixodbc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

ENV PATH="$PATH:/opt/mssql-tools/bin"

# Retorna para o usuário padrão
USER mssql

COPY create-acesso_cat.sql /tmp/create-acesso_cat.sql

CMD ( \
    /opt/mssql/bin/sqlservr & \
    PID=$! ; \
    echo "Aguardando o SQL Server iniciar..." ; \
    for i in {1..50}; do \
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" -l 1 > /dev/null 2>&1 ; \
        if [ $? -eq 0 ]; then echo "SQL Server está pronto."; break; fi ; \
        echo "Aguardando mais... ($i/50)"; sleep 1; \
    done ; \
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -i /tmp/create-acesso_cat.sql ; \
    wait $PID \
)
