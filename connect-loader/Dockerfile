FROM python:3.11-slim

WORKDIR /app

COPY connectores.py ./
COPY .env ./
COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "connectores.py"]
