import os
import time
import requests
from dotenv import load_dotenv

load_dotenv()

CONNECT_URL = os.getenv("KAFKA_CONNECT_URL")
RETRIES = 15

# Verifica se todas as variáveis estão presentes
required_envs = ["DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME", "TOPIC_PREFIX"]
missing = [var for var in required_envs if os.getenv(var) is None]
if missing:
    raise EnvironmentError(f"❌ Variáveis de ambiente ausentes: {', '.join(missing)}")

# Aguarda Kafka Connect estar disponível
for i in range(RETRIES):
    try:
        r = requests.get(CONNECT_URL)
        if r.status_code == 200:
            print("✅ Kafka Connect está disponível!")
            break
    except:
        print(f"⏳ [{i+1}/{RETRIES}] Aguardando Kafka Connect subir...")
    time.sleep(5)
else:
    print("❌ Kafka Connect não respondeu. Encerrando script.")
    exit(1)

# Configuração dos conectores
CONNECTORS = {
    "catracas-connector": {
        "name": "catracas-connector",
        "config": {
            "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
            "database.hostname": os.getenv("DB_HOST"),
            "database.port": os.getenv("DB_PORT"),
            "database.user": os.getenv("DB_USER"),
            "database.password": os.getenv("DB_PASSWORD"),
            "database.names": os.getenv("DB_NAME"),
            "database.server.name": "acesso_cat",
            "table.include.list": "dbo.Visitantes",
            "include.schema.changes": "false",
            "topic.prefix": os.getenv("TOPIC_PREFIX"),
            "database.encrypt": "false",
            "database.trustServerCertificate": "true",
            "database.ssl.mode": "disable",
            "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
            "schema.history.internal.kafka.topic": "schema-changes-acesso_cat"
        }
    }
}

# Cria ou atualiza os conectores
for name, payload in CONNECTORS.items():
    try:
        print(f"🔄 Enviando configuração para o conector '{name}'")
        # Verifica se já existe
        res_check = requests.get(f"{CONNECT_URL}/{name}")
        if res_check.status_code == 200:
            print(f"⚠️ Conector '{name}' já existe. Atualizando configuração...")
            update_res = requests.put(f"{CONNECT_URL}/{name}/config", json=payload["config"])
            print(f"🔁 Atualizado ({update_res.status_code}): {update_res.text}")
        else:
            response = requests.post(CONNECT_URL, json=payload)
            print(f"✅ Criado ({response.status_code}): {response.text}")
    except Exception as e:
        print(f"❌ Erro ao criar/atualizar conector '{name}': {e}")
