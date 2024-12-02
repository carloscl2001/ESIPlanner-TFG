## API PARA GESTIONAR LOS GRADOS##
from fastapi import APIRouter, HTTPException, status, Response
from db.models.degree import Degree
from db.schemas.degree import degree_schema, degrees_schema
from db.client import db_client
from bson import ObjectId

# Definimos el router
router = APIRouter(prefix="/degrees",
                    tags=["degrees"],
                    responses={status.HTTP_404_NOT_FOUND: {"message": "Not found"}})



#Obtener todas los grados
@router.get("/", response_model=list[Degree])
async def get_degree():
    try:
        degrees_list = list(db_client.degrees.find())  # Convierte el cursor en una lista
        return degrees_schema(degrees_list)  # Aplica el schema a la lista
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")
    

#Obtener un degree su code
@router.get("/{code}", response_model=Degree)
async def get_all_degrees(code: str):
    degree = search_degree("code", code)
    if degree:
        return degree
    raise HTTPException(status_code=404, detail="Degree not found")

#Crear un grado
@router.post("/", response_model=Degree, status_code=status.HTTP_201_CREATED)
async def create_degree(degree: Degree):
    # Verificamos si la asignatura ya existe por su code
    existing_degree = search_degree("code", degree.code)
    if existing_degree:  # Si la asignatura ya existe
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Degree already exists"
        )

    # Convertimos el objeto de Pydantic a un diccionario
    degree_dict = degree.model_dump()  # Convierte los objetos en un diccionario JSON serializable
    
    # Insertamos el nuevo degree en la base de datos
    result = db_client.degrees.insert_one(degree_dict)
    
    print(f"Grado insertado con id: {result.inserted_id}")

    # Recuperamos el degree recién creado
    new_degree = db_client.degrees.find_one({"_id": result.inserted_id})
    
    return Degree(**new_degree)

#Función para buscar un degree por un campo específico
def search_degree(field: str, key):
    degree = db_client.degrees.find_one({field: key})
    if degree:
        return Degree(**degree_schema(degree))
    return None