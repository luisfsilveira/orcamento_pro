# Usa uma imagem leve do Python
FROM python:3.9-slim

# Define o diretório de trabalho
WORKDIR /app

# Instala dependências do sistema para o Postgres
RUN apt-get update && apt-get install -y libpq-dev gcc

# Copia e instala as dependências do Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código da API
COPY app.py .

# Comando para rodar a API
CMD ["python", "app.py"]