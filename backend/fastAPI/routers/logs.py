from fastapi import APIRouter, HTTPException, status
from db.models.log import Log  # Asumo que el modelo está en este módulo
from db.schemas.log import log_schema  # Solo log_schema, no degrees_schema
from db.client import db_client
from typing import List

router = APIRouter(
    prefix="/logs",
    tags=["logs"],
    responses={status.HTTP_404_NOT_FOUND: {"message": "Not found"}}
)

# Obtener todos los logs con collection='subjects' y operation='update'
@router.get("/", response_model=List[Log])
async def get_logs_filtered():
    try:
        query = {"collection": "subjects", "operation": "update"}
        logs_list = list(db_client.logs.find(query))
        return [Log(**log_schema(log)) for log in logs_list]
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")

