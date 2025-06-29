from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

# Modelo para el usuario que usa el esquema UserSubject en lugar de modificar Subject
class Log(BaseModel):
    id: str | None = Field(default=None)
    timestamp: datetime
    collection: str  # Nombre de la colección afectada
    operation: str  # Tipo de operación (create, update, delete)
    source_file: str