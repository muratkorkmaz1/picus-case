FROM python:3.13-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY src ./src
COPY .env.example ./

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]

# AÇIKLAMA:
# Bu Dockerfile, Python FastAPI tabanlı Picus API uygulamasını container içine paketlemek için kullanılır.
# - python:3.13-slim base image'i, hem güncel hem de hafif bir Python ortamı sağlar.
# - WORKDIR /app ile container içindeki çalışma dizini /app olarak ayarlanır.
# - PYTHONDONTWRITEBYTECODE=1: .pyc bytecode dosyalarının yazılmasını engelleyerek image'i sade tutar.
# - PYTHONUNBUFFERED=1: stdout/stderr tamponlamasını kapatarak logların anlık olarak görünmesini sağlar.
# - COPY requirements.txt . ve ardından pip install, dependency layer'ını koddan ayırarak layer cache verimliliği sağlar.
# - COPY src ./src ile uygulama kaynak kodları container'a kopyalanır.
# - COPY .env.example ./ ile istenirse container içinde örnek config dosyası bulundurulabilir (production'da gerçek env değişkenleri ECS Task Definition üzerinden gelir).
# - EXPOSE 8000 ile container'ın 8000 portunda dinlediği dokümante edilir (ALB/ECS mapping için referans).
# - CMD satırı uvicorn'u 'python -m' şeklinde çalıştırarak doğru Python ortamının kullanılmasını sağlar ve
#   FastAPI uygulamasını 0.0.0.0:8000 adresinden dış dünyaya açar.
