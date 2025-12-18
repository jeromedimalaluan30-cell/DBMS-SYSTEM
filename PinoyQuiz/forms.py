# forms.py

def login_form(request):
    return {
        "username": request.form.get("username"),
        "password": request.form.get("password")
    }


def signup_form(request):
    return {
        "username": request.form.get("username"),
        "password": request.form.get("password")
    }


def question_form(request):
    return {
        "category_id": request.form.get("category_id"),
        "difficulty": request.form.get("difficulty"),
        "level": request.form.get("level"),
        "question": request.form.get("question"),
        "option_a": request.form.get("option_a"),
        "option_b": request.form.get("option_b"),
        "option_c": request.form.get("option_c"),
        "option_d": request.form.get("option_d"),
        "correct": request.form.get("correct")
    }
