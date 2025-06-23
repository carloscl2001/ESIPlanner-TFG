from pydantic import BaseModel, Field
from typing import Optional, List


# # Modelo para los eventos
class Event(BaseModel):
    date: str
    start_hour: str
    end_hour: str
    location: str

#Modelo para los tipos de clases
class Group(BaseModel):
    group_code: str
    events: List[Event]

# Modelo para la asignatura
class Subject(BaseModel):
    code: str
    name: str
    groups: List[Group]