from datetime import datetime
from typing import Any, Dict, List

from pydantic import BaseModel


class PicusItem(BaseModel):
    id: str
    payload: Dict[str, Any]
    created_at: datetime


class PutItemResponse(BaseModel):
    id: str


class GetItemResponse(BaseModel):
    item: PicusItem


class ListItemsResponse(BaseModel):
    items: List[PicusItem]


"""
AÇIKLAMA:
Bu dosya FastAPI'nin response şemalarını tanımlamak için kullanılan Pydantic modellerini içerir.
- PicusItem: DynamoDB'de saklanan tek bir kaydın temsili (id, payload, created_at).
- PutItemResponse: /picus/put endpoint'inin sadece oluşturulan id'yi döndüğü cevap modeli.
- GetItemResponse: /picus/get/{id} endpoint'inin döndüğü tek item'ı sarmalayan model.
- ListItemsResponse: /picus/list endpoint'inde birden fazla kaydı listelemek için kullanılan model.

Bu modeller, hem otomatik dokümantasyonda (Swagger UI) veri şemasını gösterir,
hem de API'nin döndüğü JSON'un tip güvenli olmasını sağlar.
"""
