def degree_schema(degree)-> dict:
    return {
        "code": degree["code"],
        "name": degree["name"],
        "subjects": degrees_schema(degree.get("subjects", [])),
    }

def degrees_schema(degrees) -> dict:
    return [degree_schema(degree) for degree in degrees]


def subject_schema(subject) -> dict:
    return{
        "code": subject["code"]
    }

def subjects_schemas(subjects) -> list:
    return [degree_schema(subject) for subject in subjects]