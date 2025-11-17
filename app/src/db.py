import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional

import boto3

from .config import AWS_REGION, DYNAMODB_TABLE

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)


def create_item(payload: Dict[str, Any]) -> str:
    item_id = str(uuid.uuid4())
    created_at = datetime.utcnow().isoformat() + "Z"

    table.put_item(
        Item={
            "id": item_id,
            "payload": payload,
            "created_at": created_at,
        }
    )

    return item_id


def get_item_by_id(item_id: str) -> Optional[Dict[str, Any]]:
    response = table.get_item(Key={"id": item_id})
    return response.get("Item")


def list_all_items() -> List[Dict[str, Any]]:
    response = table.scan()
    return response.get("Items", [])


"""
AÇIKLAMA:
Bu dosya DynamoDB ile etkileşimi soyutlayan yardımcı fonksiyonları içerir.
- dynamodb = boto3.resource(...): AWS_REGION bilgisini kullanarak DynamoDB resource'u oluşturur.
- table = dynamodb.Table(DYNAMODB_TABLE): Uygulamanın çalışacağı tabloyu temsil eder.

Fonksiyonlar:
- create_item(payload): Rastgele bir UUID üretir, gelen payload'ı ve created_at zamanını
  'picus' tablosuna yazar ve üretilen id'yi döner.
- get_item_by_id(item_id): Verilen id'ye göre tablodan tek bir kaydı getirir.
- list_all_items(): Tablodaki tüm kayıtları scan ile döner.

Bu katman sayesinde routes tarafı direkt boto3 çağrılarıyla uğraşmak zorunda kalmaz;
DynamoDB erişimi tek bir yerde toplanmış olur ve test edilebilirlik artar.
"""
