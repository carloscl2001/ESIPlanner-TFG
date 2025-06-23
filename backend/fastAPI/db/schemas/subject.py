def subject_schema(subject) -> dict:
    return {
        "code": subject["code"],
        "name": subject["name"],
        "groups": groups_schema(subject.get("groups", [])),  # Aplica el esquema de clases
    }

def subjects_schema(subjects) -> list:
    return [subject_schema(subject) for subject in subjects]




def group_schema(group) -> dict:
    return {
        "group_code": group["group_code"],
        "events": events_schema(group.get("events", [])),  # Aplica el esquema de eventos
    }

def groups_schema(groups) -> list:
    return [group_schema(group) for group in groups]



def event_schema(event) -> dict:
    return {
        "date": event["date"],
        "start_hour": event["start_hour"],
        "end_hour": event["end_hour"],
        "location": event["location"],
    }

def events_schema(events) -> list:
    return [event_schema(event) for event in events]

