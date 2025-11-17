from fastapi import FastAPI
from .routes import picus as picus_routes

app = FastAPI(title="Picus Case API")

app.include_router(picus_routes.router, prefix="/picus", tags=["picus"])

"""
AÇIKLAMA:
Bu dosya FastAPI uygulamasının başlangıç noktasını tanımlar.
- FastAPI instance'ı oluşturulur.
- /picus altındaki tüm endpoint'ler routes/picus.py içinden include edilir.
- title alanı Swagger UI gibi otomatik dokümantasyonda proje adı olarak görünür.
"""
