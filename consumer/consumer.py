import json
import requests
import os
import time
from confluent_kafka import Consumer
from telegram import Bot
from telegram.error import InvalidToken
from dotenv import load_dotenv

# ========== Carregar variáveis do .env ==========
load_dotenv()

# Verifica se todas as variáveis obrigatórias estão definidas
REQUIRED_VARS = ["KAFKA_TOPIC", "TELEGRAM_TOKEN", "TELEGRAM_CHAT_ID", "API_URL", "API_URL_2", "API_TOKEN"]
missing_vars = [var for var in REQUIRED_VARS if not os.getenv(var)]
if missing_vars:
    raise EnvironmentError(f"❌ Variáveis de ambiente faltando: {', '.join(missing_vars)}")

# ========== Variáveis ==========
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC")
TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
TELEGRAM_CHAT_ID = int(os.getenv("TELEGRAM_CHAT_ID"))
API_TOKEN = os.getenv("API_TOKEN")
API_URL = os.getenv("API_URL")
API_URL_2 = os.getenv("API_URL_2")

# Cabeçalho de autenticação correto
HEADERS = {
    "Authorization": API_TOKEN,
    "Accept": "application/json"
}

# ========== Kafka Consumer ==========
KAFKA_CONFIG = {
    'bootstrap.servers': 'kafka:9092',
    'group.id': 'bot-integracao-endpoint',
    'auto.offset.reset': 'earliest'
}
consumer = Consumer(KAFKA_CONFIG)
consumer.subscribe([KAFKA_TOPIC])

# ========== Telegram Bot ==========
bot = None
try:
    bot = Bot(token=TELEGRAM_TOKEN)
except InvalidToken:
    print("❌ TELEGRAM_TOKEN inválido. O bot não será usado.")
except Exception as e:
    print(f"❌ Erro ao inicializar o bot do Telegram: {e}")

# ========== Funções Auxiliares ==========

def consultar_api_externa(cpf, tentativas=3, delay=2):
    """Consulta duas APIs externas com retry automático."""
    for url in [API_URL, API_URL_2]:
        for tentativa in range(1, tentativas + 1):
            try:
                print(f"🔍 Consultando {url} (tentativa {tentativa})...")
                response = requests.get(url, params={'cpf': cpf}, headers=HEADERS, timeout=10)
                response.raise_for_status()
                print(f"✅ Resposta recebida da API: {url}")
                return response.json()
            except requests.HTTPError as e:
                print(f"⚠️ HTTP error {e.response.status_code} ao consultar {url}: {e}")
                if e.response.status_code == 403:
                    print("🔒 Verifique se o token está correto e autorizado.")
                    break  # 403 não adianta tentar de novo
            except Exception as e:
                print(f"⚠️ Erro ao consultar {url}: {e}")
            time.sleep(delay)
    print("❌ Nenhuma API retornou resultado válido após todas as tentativas.")
    return {}

def enviar_para_telegram(mensagem):
    """Envia mensagem para o Telegram, se o bot estiver disponível."""
    if not bot:
        print("⚠️ Bot do Telegram indisponível. Mensagem não enviada.")
        return
    try:
        bot.send_message(chat_id=TELEGRAM_CHAT_ID, text=mensagem)
        print("✅ Mensagem enviada ao Telegram.")
    except Exception as e:
        print(f"❌ Erro ao enviar mensagem ao Telegram: {e}")

# ========== Loop principal ==========
print("🟢 Iniciando consumo de mensagens do Kafka...")

try:
    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue
        if msg.error():
            print("❌ Erro no Kafka:", msg.error())
            continue

        try:
            payload = json.loads(msg.value().decode('utf-8'))
            print("📥 Mensagem recebida:", payload)

            dados = payload.get("payload", {}).get("after", {})
            documento = dados.get("Documento")

            if documento:
                resultado = consultar_api_externa(documento)
                if resultado.get("hits", 0) > 0:
                    mensagem = (
                        f"🔔 *Alerta de Dados Encontrados*\n\n"
                        f"📌 *Documento: {documento}\n"
                        f"📎 *Origem:* Minha aplicação de busca\n"
                        f"🔗 Verifique manualmente no sistema interno.\n"
                    )
                    enviar_para_telegram(mensagem)
                else:
                    print(f"🟡 Documento {documento} sem correspondência na API externa.")
            else:
                print("ℹ️ Campo 'Documento' não encontrado no payload.")

        except json.JSONDecodeError:
            print("⚠️ Erro ao decodificar JSON da mensagem.")
        except Exception as e:
            print(f"❌ Erro inesperado ao processar mensagem: {e}")

except KeyboardInterrupt:
    print("🛑 Encerrando consumo manualmente.")
finally:
    consumer.close()
    print("🧹 Conexão com o Kafka encerrada.")
