from typing import Any, Dict

from fastapi import APIRouter, HTTPException

from .. import db
from ..models import GetItemResponse, ListItemsResponse, PutItemResponse

router = APIRouter()


@router.get("/health")
def health_check():
    return {"status": "ok", "message": "Picus API is alive"}


@router.post("/put", response_model=PutItemResponse)
def put_item(payload: Dict[str, Any]):
    item_id = db.create_item(payload)
    return {"id": item_id}


@router.get("/get/{item_id}", response_model=GetItemResponse)
def get_item(item_id: str):
    item = db.get_item_by_id(item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"item": item}


@router.get("/list", response_model=ListItemsResponse)
def list_items():
    items = db.list_all_items()
    return {"items": items}


"""
AÇIKLAMA:
Bu dosya /picus altında çalışan tüm HTTP endpoint'lerini tanımlar.

Endpoint'ler:
- GET /picus/health:
  Servisin ayakta olup olmadığını kontrol etmek için basit bir health-check endpoint'i.

- POST /picus/put:
  İstek gövdesinde gelen JSON payload'ı alır, db.create_item ile DynamoDB'ye kaydeder
  ve oluşturulan id'yi döner. Gönderilen JSON herhangi bir şemaya bağlı değildir;
  ne gelirse payload alanı altında saklanır.

- GET /picus/get/{item_id}:
  Verilen item_id'ye göre DynamoDB'den tek bir kaydı getirir. Kayıt bulunamazsa 404 hatası döner.

- GET /picus/list:
  DynamoDB tablosundaki tüm kayıtları scan ile getirir ve liste olarak döner.

Bu router, main.py içinde /picus prefix'i ile include edildiği için,
gerçek URL'ler /picus/put, /picus/get/{id}, /picus/list şeklindedir.
"""
