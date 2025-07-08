FROM python:3.10-slim

WORKDIR /app

# Copiar primeiro o requirements para aproveitar o cache do Docker
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Depois copia o restante
COPY . .

CMD ["python", "consumer.py"]
