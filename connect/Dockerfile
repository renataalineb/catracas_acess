FROM confluentinc/cp-kafka-connect:7.4.0

# Instala o conector Debezium SQL Server versão 2.4.1.Final
RUN curl -L https://repo1.maven.org/maven2/io/debezium/debezium-connector-sqlserver/2.4.1.Final/debezium-connector-sqlserver-2.4.1.Final-plugin.tar.gz \
  | tar -xz -C /usr/share/confluent-hub-components

ENV CONNECT_PLUGIN_PATH="/usr/share/confluent-hub-components"
