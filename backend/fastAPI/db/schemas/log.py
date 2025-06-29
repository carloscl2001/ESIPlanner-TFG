
def log_schema(log) -> dict:
    return {
        "id": str(log["_id"]),
        "timestamp": log["timestamp"],
        "collection": log["collection"],
        "operation": log["operation"],
        "source_file": log["source_file"],
    }

def logs_schema(logs) -> list:
    return [log_schema(log) for log in logs]