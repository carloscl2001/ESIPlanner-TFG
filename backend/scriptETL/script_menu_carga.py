#!/usr/bin/env python3
import json
import os
from datetime import datetime
from pymongo.errors import BulkWriteError
from tqdm import tqdm
import sys
from pathlib import Path

# Configuración de paths
servidor_path = Path(__file__).parent.parent  # Sube a /servidor
sys.path.append(str(servidor_path))
from fastAPI.db.client import db_client

# Variable global para almacenar archivos cargados
loaded_files = {
    'subjects': set(),
    'degrees': set(),
    'mapping': set(),
    'departments': set()
}

# Configuración de carpetas y colecciones
FOLDER_CONFIG = {
    'archivos_asignaturas': 'subjects',
    'archivos_grados': 'degrees',
    'archivos_mapeo': 'mapping',
    'archivos_departamentos': 'departments'
}

class ConsoleOutput:
    """Clase para manejar la salida a consola"""
    @staticmethod
    def print_header(title):
        print("\n" + "="*60)
        print(title.center(60))
        print("="*60)

    @staticmethod
    def print_header_processing(title):
        print("\n" + "_"*60)
        print(title.center(60))
        print("_"*60)

    @staticmethod
    def print_finish(title1, title2):
        print("\n" + "="*60)
        print(title1.center(60))
        print(title2.center(60))
        print("="*60)
    
    @staticmethod
    def print_menu(title, options):
        print("\n" + "-"*60)
        print(title.center(60))
        print("-"*60)
        for key, option in options.items():
            print(f" {key}. {option['label']}")
        print("-"*60)
    
    @staticmethod
    def print_success(message):
        print(f"[EXITO] {message}")
    
    @staticmethod
    def print_warning(message):
        print(f"[!] {message}")
    
    @staticmethod
    def print_info(message):
        print(f"[i] {message}")

def log_changes(collection_name: str, operation: str, filename: str, changes: dict):
    """Registra cambios en la colección de log"""
    log_entry = {
        "timestamp": datetime.now(),
        "collection": collection_name,
        "operation": operation,
        "source_file": filename,
        "changes": changes,
    }
    
    try:
        db_client['logs'].insert_one(log_entry)
    except Exception as e:
        ConsoleOutput.print_warning(f"No se pudo registrar en el log: {str(e)}")

def show_menu():
    """Muestra el menú principal y maneja la selección"""
    menu_options = {
        '1': {
            'label': 'Subida completa de todos los archivos (borrar e insertar)',
            'action': full_clean_load
        },
        '2': {
            'label': 'Subida dicional de archivos específicos (sobreescribir o insertar) y generación de notificaciones en asignaturas(existan o no cambios)',
            'action': additional_load_menu
        },
        '3': {
            'label': 'Ver estadísticas detalladas',
            'action': show_detailed_stats
        },
        '4': {
            'label': 'Salir',
            'action': exit_program
        }
    }
    
    while True:
        ConsoleOutput.print_menu("GESTOR DE CARGA DE DATOS", menu_options)
        choice = input("Seleccione una opción (1-4): ")
        
        if choice in menu_options:
            menu_options[choice]['action']()
        else:
            ConsoleOutput.print_warning("Opción no válida. Intente nuevamente.")

def full_clean_load():
    """Borra toda la colección y realiza una carga nueva"""
    ConsoleOutput.print_header("REALIZANDO CARGA COMPLETA (BORRAR TODO E INSERTAR)")
    
    start_time = datetime.now()
    total_docs = 0
    
    # Limpiar registro de archivos cargados
    global loaded_files
    loaded_files = {col: set() for col in FOLDER_CONFIG.values()}
    
    for folder, collection in FOLDER_CONFIG.items():
        if not os.path.exists(folder):
            ConsoleOutput.print_warning(f"Carpeta no encontrada: {folder}")
            continue

        # Manejo especial para archivos_mapeo (solo mapeo.json)
        if folder == 'archivos_mapeo':
            files = ['mapeo.json'] if os.path.exists(os.path.join(folder, 'mapeo.json')) else []
        else:
            files = [f for f in os.listdir(folder) if f.endswith('.json')]
        
        if not files:
            ConsoleOutput.print_warning(f"No hay archivos JSON en {folder}")
            continue

        ConsoleOutput.print_header_processing(f"PROCESANDO: {folder} -> {collection}")

        # 1. Borrado completo
        count_before = db_client[collection].estimated_document_count()
        deleted_result = db_client[collection].delete_many({})
        
        log_changes(
            collection_name=collection,
            operation="delete",
            filename="FULL_CLEAN_LOAD",
            changes={
                "deleted_count": deleted_result.deleted_count,
                "operation": "full_clean_load",
                "details": f"Se eliminaron todos los documentos ({deleted_result.deleted_count}) de la colección {collection}"
            }
        )
        
        ConsoleOutput.print_success(f"Colección {collection} borrada. Documentos eliminados: {count_before}")
        
        # 2. Carga de archivos
        inserted = 0
        processed_files = []
        
        for filename in tqdm(files, desc=f"Cargando {collection}"):
            loaded_files[collection].add(filename)
            processed_files.append(filename)
            filepath = os.path.join(folder, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                    # Manejo especial para mapeo.json
                    if filename == 'mapeo.json':
                        # Extraer el array de mapeo del objeto anidado
                        if isinstance(data, dict) and 'mapping' in data:
                            mapping_data = data['mapping']
                        else:
                            mapping_data = data
                        
                        mapping_doc = {
                            'name': 'asignaturasInfo_mapping',
                            'last_update': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                            'mapping': mapping_data
                        }
                        result = db_client[collection].insert_one(mapping_doc)
                        inserted += 1
                    else:
                        if isinstance(data, list):
                            result = db_client[collection].insert_many(data)
                            inserted += len(result.inserted_ids)
                        else:
                            result = db_client[collection].insert_one(data)
                            inserted += 1
            except Exception as e:
                ConsoleOutput.print_warning(f"Error en {filename}: {str(e)}")
                continue
        
        log_changes(
            collection_name=collection,
            operation="insert",
            filename="MULTIPLE_FILES",
            changes={
                "inserted_count": inserted,
                "operation": "bulk_insert",
                "processed_files": processed_files,
                "file_count": len(processed_files),
                "details": f"Se insertaron {inserted} documentos desde {len(processed_files)} archivos"
            }
        )
        
        total_docs += inserted
        ConsoleOutput.print_success(f"Documentos insertados en {collection}: {inserted}")
    
    duration = (datetime.now() - start_time).total_seconds()
    ConsoleOutput.print_finish(f"CARGA COMPLETA FINALIZADA en {duration:.2f} segundos", f"Total documentos insertados: {total_docs}")

def additional_load_menu():
    """Menú para carga adicional de archivos específicos"""
    while True:
        submenu_options = {
            '1': {
                'label': 'Añadir/actualizar asignaturas y generar notificaciones(aunque no haya cambios)',
                'action': lambda: process_custom_files('archivos_asignaturas', 'subjects')
            },
            '2': {
                'label': 'Añadir/actualizar grados',
                'action': lambda: process_custom_files('archivos_grados', 'degrees')
            },
            '3': {
                'label': 'Añadir/actualizar mapeo',
                'action': lambda: process_custom_files('archivos_mapeo', 'mapping')
            },
            '4': {
                'label': 'Añadir/actualizar departamentos',
                'action': lambda: process_custom_files('archivos_departamentos', 'departments')
            },
            '5': {
                'label': 'Volver al menú principal',
                'action': lambda: None
            }
        }
        
        ConsoleOutput.print_menu("CARGA ADICIONAL DE ARCHIVOS ESPECIFICOS", submenu_options)
        choice = input("Seleccione una opción (1-5): ")
        
        if choice in submenu_options:
            if choice == '5':
                return
            submenu_options[choice]['action']()
        else:
            ConsoleOutput.print_warning("Opción no válida. Intente nuevamente.")

def process_custom_files(folder_path: str, collection_name: str):
    """Procesa archivos específicos y registra los nombres"""
    try:
        if not os.path.exists(folder_path):
            ConsoleOutput.print_warning(f"Carpeta no encontrada: {folder_path}")
            return

        # Manejo especial para archivos_mapeo
        if folder_path == 'archivos_mapeo':
            available_files = ['mapeo.json'] if os.path.exists(os.path.join(folder_path, 'mapeo.json')) else []
        else:
            available_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]
        
        if not available_files:
            ConsoleOutput.print_warning(f"No hay archivos JSON en {folder_path}")
            return

        ConsoleOutput.print_info("\nArchivos disponibles:")
        for i, filename in enumerate(available_files, 1):
            print(f" {i}. {filename}")
        
        file_input = input("\nIngrese los números o nombres de los archivos a cargar (separados por espacios): ")
        
        selected_files = []
        for item in file_input.split():
            if item.isdigit():
                index = int(item) - 1
                if 0 <= index < len(available_files):
                    selected_files.append(available_files[index])
            else:
                if item in available_files:
                    selected_files.append(item)
        
        if not selected_files:
            ConsoleOutput.print_warning("No se seleccionaron archivos válidos")
            return

        ConsoleOutput.print_header(f"PROCESANDO {len(selected_files)} ARCHIVOS EN {collection_name}")
        
        current_count = db_client[collection_name].estimated_document_count()
        ConsoleOutput.print_info(f"Documentos actuales en {collection_name}: {current_count}")
        
        total_inserted = 0
        duplicates = 0
        
        for filename in selected_files:
            loaded_files[collection_name].add(filename)
            filepath = os.path.join(folder_path, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                    # Manejo especial para mapeo.json
                    if filename == 'mapeo.json':
                        # Extraer el array de mapeo del objeto anidado
                        if isinstance(data, dict) and 'mapping' in data:
                            mapping_data = data['mapping']
                        else:
                            mapping_data = data
                        
                        result = db_client[collection_name].update_one(
                            {'name': 'asignaturasInfo_mapping'},
                            {'$set': {
                                'mapping': mapping_data,
                                'last_update': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                            }},
                            upsert=True
                        )
                        
                        if result.upserted_id:
                            total_inserted += 1
                            log_changes(
                                collection_name=collection_name,
                                operation="insert",
                                filename=filename,
                                changes={
                                    "document_id": str(result.upserted_id),
                                    "operation": "upsert_insert",
                                    "details": f"Nuevo mapeo insertado desde {filename}"
                                }
                            )
                        else:
                            duplicates += 1
                            log_changes(
                                collection_name=collection_name,
                                operation="update",
                                filename=filename,
                                changes={
                                    "operation": "upsert_update",
                                    "details": f"Mapeo actualizado desde {filename}"
                                }
                            )
                        continue
                    
                    # Procesamiento normal para otros archivos
                    if isinstance(data, list):
                        for doc in data:
                            try:
                                # Definir el criterio de filtro según la colección
                                if collection_name == 'mapping':
                                    filter_criteria = {'name': doc.get('name')}  # Para mapeo usar name
                                else:
                                    filter_criteria = {'code': doc.get('code')}  # Para todo lo demás usar code
                                
                                result = db_client[collection_name].update_one(
                                    filter_criteria,
                                    {'$set': doc},
                                    upsert=True
                                )
                                if result.upserted_id:
                                    total_inserted += 1
                                    log_changes(
                                        collection_name=collection_name,
                                        operation="insert",
                                        filename=filename,
                                        changes={
                                            "document_id": str(result.upserted_id),
                                            "operation": "upsert_insert",
                                            "details": f"Nuevo documento insertado desde {filename}"
                                        }
                                    )
                                else:
                                    duplicates += 1
                                    log_changes(
                                        collection_name=collection_name,
                                        operation="update",
                                        filename=filename,
                                        changes={
                                            "document_id": str(doc.get('code', doc.get('name', doc.get('_id')))),
                                            "operation": "upsert_update",
                                            "details": f"Documento actualizado desde {filename}"
                                        }
                                    )
                            except Exception as e:
                                ConsoleOutput.print_warning(f"Error en documento: {str(e)}")
                    else:
                        try:
                            # Definir el criterio de filtro según la colección
                            if collection_name == 'mapping':
                                filter_criteria = {'name': data.get('name')}  # Para mapeo usar name
                            else:
                                filter_criteria = {'code': data.get('code')}  # Para todo lo demás usar code
                            
                            result = db_client[collection_name].update_one(
                                filter_criteria,
                                {'$set': data},
                                upsert=True
                            )
                            if result.upserted_id:
                                total_inserted += 1
                                log_changes(
                                    collection_name=collection_name,
                                    operation="insert",
                                    filename=filename,
                                    changes={
                                        "document_id": str(result.upserted_id),
                                        "operation": "upsert_insert",
                                        "details": f"Nuevo documento insertado desde {filename}"
                                    }
                                )
                            else:
                                duplicates += 1
                                log_changes(
                                    collection_name=collection_name,
                                    operation="update",
                                    filename=filename,
                                    changes={
                                        "document_id": str(data.get('code', data.get('name', data.get('_id')))),
                                        "operation": "upsert_update",
                                        "details": f"Documento actualizado desde {filename}"
                                    }
                                )
                        except Exception as e:
                            ConsoleOutput.print_warning(f"Error en documento: {str(e)}")
                            
            except Exception as e:
                ConsoleOutput.print_warning(f"Error procesando {filename}: {str(e)}")
                continue
        
        ConsoleOutput.print_success(f"\nResumen de la carga:")
        ConsoleOutput.print_success(f"- Documentos nuevos insertados: {total_inserted}")
        ConsoleOutput.print_success(f"- Documentos actualizados: {duplicates}")
        
        new_count = db_client[collection_name].estimated_document_count()
        ConsoleOutput.print_success(f"Total documentos en {collection_name}: {new_count}")
        
    except Exception as e:
        ConsoleOutput.print_warning(f"Error: {str(e)}")

def show_detailed_stats():
    """Muestra estadísticas detalladas incluyendo archivos cargados"""
    ConsoleOutput.print_header("ESTADÍSTICAS DETALLADAS")
    collections = {
        'subjects': 'Asignaturas',
        'degrees': 'Grados',
        'mapping': 'Mapeos',
        'departments': 'Departamentos',
        'logs': 'Registros de Cambios'
    }
    
    print("\nDocumentos en MongoDB:")
    for col, name in collections.items():
        try:
            count = db_client[col].estimated_document_count()
            print(f"  {name+':':<20}{count:>10}")
            
            if col in loaded_files and loaded_files[col]:
                print(f"  Archivos cargados ({len(loaded_files[col])}):")
                for i, filename in enumerate(sorted(loaded_files[col]), 1):
                    print(f"    {i}. {filename}")
            elif col in loaded_files:
                print("  Ningún archivo cargado recientemente")
                
            # Mostrar info adicional para el mapeo
            if col == 'mapping':
                mapping_data = db_client[col].find_one({'name': 'asignaturasInfo_mapping'})
                if mapping_data:
                    print(f"  Mapeo actualizado: {mapping_data.get('last_update', 'Desconocido')}")
                    print(f"  Entradas en el mapeo: {len(mapping_data.get('mapping', []))}")
            
        except Exception as e:
            ConsoleOutput.print_warning(f"No se pudo acceder a la colección {col}: {str(e)}")

    # Mostrar los últimos 5 registros de cambios
    try:
        print("\nÚltimos 5 registros de cambios:")
        last_logs = db_client['logs'].find().sort('timestamp', -1).limit(5)
        for log in last_logs:
            print(f"\n  [{log['timestamp']}] {log['collection']}.{log['operation']}")
            print(f"  Archivo: {log['source_file']}")
            print("  Detalles:")
            
            if log['source_file'] in ["FULL_CLEAN_LOAD", "FULL_OVERWRITE_LOAD"]:
                print(f"    Documentos afectados: {log['changes']['deleted_count']}")
                print(f"    Operación: {log['changes']['operation']}")
                print(f"    {log['changes']['details']}")
                
            elif log['source_file'] == "MULTIPLE_FILES":
                print(f"    Documentos insertados: {log['changes']['inserted_count']}")
                print(f"    Archivos procesados ({log['changes']['file_count']}):")
                for i, fname in enumerate(log['changes']['processed_files'], 1):
                    print(f"      {i}. {fname}")
                print(f"    {log['changes']['details']}")
            else:
                print(f"    ID Documento: {log['changes'].get('document_id', 'N/A')}")
                print(f"    Operación: {log['changes']['operation']}")
                print(f"    {log['changes']['details']}")
    except Exception as e:
        ConsoleOutput.print_warning(f"No se pudieron obtener los registros de cambios: {str(e)}")

def exit_program():
    """Sale del programa"""
    ConsoleOutput.print_header("FIN DEL PROGRAMA")
    sys.exit(0)

if __name__ == "__main__":
    try:
        # Crear índices únicos
        db_client['subjects'].create_index([("code", 1)], unique=True)
        db_client['degrees'].create_index([("code", 1)], unique=True)
        db_client['departments'].create_index([("code", 1)], unique=True)
        db_client['mapping'].create_index([("name", 1)], unique=True)  # Índice único para name en mapping
        
        # Índices para logs
        db_client['logs'].create_index([("timestamp", -1)])
        db_client['logs'].create_index([("collection", 1)])
        db_client['logs'].create_index([("operation", 1)])
        db_client['logs'].create_index([("source_file", 1)])
        
        show_menu()
    except KeyboardInterrupt:
        ConsoleOutput.print_warning("\nOperación cancelada por el usuario")
    except Exception as e:
        ConsoleOutput.print_warning(f"Error inesperado: {str(e)}")
    finally:
        ConsoleOutput.print_header("SESIÓN TERMINADA")