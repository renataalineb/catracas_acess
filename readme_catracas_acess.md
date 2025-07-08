
# catracas_acess

Projeto para captura de mudanças em tempo real em uma tabela SQL Server usando **Debezium**, **Kafka** e envio de alertas para o **Telegram** via **consumer Python**.

---

## Visão Geral

Este projeto implementa uma arquitetura de captura de dados em tempo real usando **SQL Server**, **Debezium**, **Kafka**, e **consumidores Python**. A seguir, a descrição dos diretórios e arquivos:

- **Debezium** (CDC – Change Data Capture)
- **Apache Kafka** (mensageria)
- **Kafka Connect** (integração com banco)
- **Python Consumer** (envia alertas para o Telegram)
- **Kafdrop** (dashboard web para visualizar tópicos Kafka)
- **Connect Loader** (serviço Python para registrar conectores automaticamente)

---

## Estrutura do Projeto

      .
      ├── connect/                     # Dockerfile para a imagem do Kafka Connect com Debezium
      ├── connect-loader/              # Scripts Python para registrar conectores automaticamente
      │   ├── connectores.py           # Script principal de registro
      │   ├── Dockerfile               # Imagem para execução do connectores.py
      │   └── requirements.txt         # Dependências do Python para o loader
      ├── consumer/                    # Consumer Kafka implementado em Python
      │   ├── consumer.py              # Lógica de consumo, consulta API e envio para Telegram
      │   ├── Dockerfile               # Imagem para o consumer Python
      │   └── requirements.txt         # Dependências do Python para o consumer
      ├── docker-compose.yaml          # Orquestração de todos os serviços Docker
      ├── LICENSE                      # Licença do projeto (opcional)
      ├── readme_catracas_acess.md       # Este arquivo README
      ├── sql_scripts/                 # Scripts SQL auxiliares para configuração inicial e testes
      │   ├── Script_DLH-213- CREATE_TABLE_EXEMPLO.sql # Exemplo de criação de tabela
      │   └── Script_DLH-213_INSERT_INTO_EXEMPLO.sql   # Exemplo de inserção de dados
      └── sqlserver-custom/            # Customização da imagem do SQL Server
          ├── create-acesso_cat.sql    # Script para criar DB/tabelas e habilitar CDC
          └── Dockerfile               # Aplica o script ao iniciar o SQL Server

---

### Fluxo de Funcionamento

1. Tabela no **SQL Server** recebe novos registros.
2. **Debezium**, via **Kafka Connect**, detecta as mudanças (CDC) e publica no **tópico Kafka**.
3. O **consumidor Python** escuta esse tópico, processa os dados, consulta **APIs externas** (por exemplo, procedimentos policiais) e envia **alertas para o Telegram**.
4. O serviço **connect-loader** registra os conectores automaticamente quando os containers sobem, evitando configuração manual.

---

### Observações Importantes

- As APIs externas exigem **token de autenticação** e podem retornar **403** se o token estiver incorreto ou o CPF for inválido.
- A pasta `sqlserver-custom` não utiliza chaves de autenticação para facilitar o desenvolvimento em ambientes genéricos.
- Ao derrubar e subir os containers novamente, o conector pode reler os dados desde o **início do log CDC**, dependendo da configuração do offset do Kafka.


## Subindo o ambiente com Docker

```bash
docker-compose up --build
```

Serviços incluídos:

- SQL Server (com CDC ativado)
- Zookeeper
- Kafka
- Kafka Connect (com plugin Debezium)
- Kafdrop (UI de visualização dos tópicos)
- Connect Loader (registra conectores via API REST)
- Consumer (Python)

Volumes persistentes:

- `sqlserver_data`
- `connect_data`

---

## Registro automático do conector Debezium

O serviço `connect-loader` realiza o registro do conector via Kafka Connect REST API, usando o script `connectores.py`.

> O JSON do conector pode ser modificado dentro do `connect-loader/connectores.py`, conforme necessário.

Exemplo de payload usado:

```json
{
  "name": "catracas-connector",
  "config": {
    "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
    "database.hostname": "${DB_HOST}",
    "database.port": "${DB_PORT}",
    "database.user": "${DB_USER}",
    "database.password": "${DB_PASSWORD}",
    "database.names": "${DB_NAME}",
    "database.server.name": "acesso_cat",
    "table.include.list": "dbo.Visitantes",
    "include.schema.changes": "false",
    "topic.prefix": "${TOPIC_PREFIX}",
    "database.encrypt": "false",
    "database.trustServerCertificate": "true",
    "database.ssl.mode": "disable",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes-acesso_cat"
  }
}
```

### Verificar status:

```bash
curl http://localhost:8083/connectors | jq
curl http://localhost:8083/connectors/db-connector/status | jq
```

---

## Consumer Python

O container `consumer` roda um script `consumer.py` que atua como um observador ativo para eventos relacionados a novos visitantes, especificamente para alertas de ocorrências judiciais. Ele é configurado para:

- Consumir mensagens Kafka: Lê continuamente mensagens do tópico definido pela variável de ambiente `KAFKA_TOPIC` (que, com base na configuração do produtor, espera-se que seja `sqlserver-acesso-cat.acesso_cat.dbo.Visitantes`).
- Extrair dados do visitante: Após receber uma mensagem, extrai o campo `Documento` do payload (que representa o CPF/documento do visitante).
- Consultar APIs externas: Utiliza o `Documento` para realizar consultas em duas APIs externas (URLs definidas por `API_URL` e `API_URL_2`), com um mecanismo de retry automático e tratamento de erros para garantir resiliência. Essas APIs são consultadas para verificar ocorrências judiciais associadas ao documento.
- Enviar alertas para o Telegram: Se a consulta nas APIs externas identificar que o campo `"hits"` (indicando ocorrências) é maior que zero, uma mensagem de alerta formatada é enviada para um chat específico do Telegram (definido por `TELEGRAM_CHAT_ID`), informando sobre a ocorrência judicial.

Variáveis de Ambiente Essenciais

  O script depende das seguintes variáveis de ambiente, que devem ser configuradas no arquivo `.env` ou no ambiente de execução:

  `KAFKA_TOPIC`: O nome do tópico Kafka a ser consumido (ex: `sqlserver-acesso-cat.acesso_cat.dbo.Visitantes`).

  `TELEGRAM_TOKEN`: O token de acesso do seu bot do Telegram.

  `TELEGRAM_CHAT_ID`: O ID numérico do chat ou grupo do Telegram para onde as mensagens serão enviadas.

  `API_URL`: A URL da primeira API externa a ser consultada para ocorrências.

  `API_URL_2`: A URL da segunda API externa a ser consultada para ocorrências (fallback).

  `API_TOKEN`: O token de autenticação (Authorization header) para acessar as APIs externas.


Monitoramento dos Logs
  Para acompanhar a execução e verificar o comportamento do consumer em tempo real, você pode visualizar os logs do container:

```bash
docker logs -f catracas_ssp_consumer_1
```

---

## Detalhes do `connect-loader/`

Este diretório contém o serviço responsável por registrar automaticamente conectores no **Kafka Connect** usando a API REST.

### Estrutura da pasta

```plaintext
    connect-loader/
    ├── connectores.py       # Script Python para registrar conectores
    ├── Dockerfile           # Imagem para rodar o script
    └── requirements.txt     # Dependências do Python
```

### Lógica do `connectores.py`

Esse script é responsável por automatizar a criação ou atualização de conectores Kafka Connect para capturar alterações via Debezium.

#### Etapas:

1. **Valida variáveis de ambiente obrigatórias**: como host, porta, usuário, senha e banco.
2. **Aguarda o Kafka Connect ficar disponível** (com até 15 tentativas).
3. **Define os conectores com base nas variáveis**.
4. **Cria ou atualiza conectores** via API REST do Kafka Connect:
   - Se já existir, atualiza a configuração (`PUT`).
   - Se não existir, cria um novo conector (`POST`).

> O conector `catracas-connector` monitora a tabela `dbo.Visitantes` do banco SQL Server e publica as mudanças no tópico Kafka prefixado.

---

## Testando

Execute no SQL Server:

```sql
BEGIN
    DECLARE @cod_pessoa INT;

    -- 1. Insere uma nova pessoa
    INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 987654321098765);
    SET @cod_pessoa = SCOPE_IDENTITY();

    -- 2. Insere um novo visitante com um documento que você pode testar na API externa
    INSERT INTO dbo.Visitantes (
        COD_PESSOA, Nome, Documento, Empresa, Fone, Observacao,
        COD_ZT, COD_PERFIL, Bloqueado, IgnorarRota, IgnorarAntiPassback,
        IgnorarEntradas, IDExportacao, SenhaAcesso, enviarCartaoSemFace
    )
    VALUES (
        @cod_pessoa, N'Visitante Teste CDC', N'99988877766', N'Empresa Teste CDC', N'(11)99999-9111', N'Teste de integração',
        0, 1, 0, 0, 0, 0, NULL, NULL, 0
    );
END;
```

Resultado esperado:

- Kafka Connect / Debezium: O conector `catracas-connector` (Debezium) capturará a mudança na tabela `dbo.Visitantes`.
- Tópico Kafka: Um novo evento (registro) será publicado no tópico Kafka configurado para `dbo.Visitantes` (ex: `sqlserver-acesso-cat.acesso_cat.dbo.Visitantes`).
- Consumer Python: O `consumer.py` consumirá essa nova mensagem do tópico, extrairá o campo `Documento` (`99988877766` neste exemplo).
- Consulta à API Externa: O consumer utilizará o `Documento` para consultar as APIs externas configuradas (`API_URL`, `API_URL_2`).
- Alerta no Telegram:

    Se as APIs externas retornarem um `"hits"` maior que zero para o documento, o consumer enviará uma mensagem de alerta para o chat do Telegram configurado.

    Se as APIs externas não retornarem ocorrências (`"hits"` igual a zero), o consumer registrará essa informação nos logs, mas nenhuma mensagem será enviada ao Telegram, indicando que o documento não possui ocorrências detectadas.
---

## Comandos úteis

### Listar tópicos Kafka:

```bash
docker exec -it catracas_acess_kafka_1   kafka-topics --bootstrap-server localhost:9092 --list
```

### Ler mensagens de um tópico:

```bash
docker exec -it catracas_acess_kafka_1 kafka-console-consumer --bootstrap-server localhost:9092 --topic sqlserver-acesso-cat.acesso_cat.dbo.Visitantes --from-beginning
```

### Histórico de esquema(útil para depuração do Debezium):

```bash
docker exec -it catracas_acess_kafka_1 kafka-console-consumer --bootstrap-server localhost:9092 --topic schema-changes-acesso_cat --from-beginning
```

---

> Desenvolvido por **Renata Barbosa**  
> Projeto: `catracas_acess`  
> Em caso de dúvidas, consulte a [documentação oficial](https://debezium.io/documentation/) do Debezium, Kafka Connect e CDC no SQL Server.
