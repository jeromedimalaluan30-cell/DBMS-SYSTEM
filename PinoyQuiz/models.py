# models.py
from flask_mysqldb import MySQL

mysql = None

def init_db(app):
    global mysql
    mysql = MySQL(app)


# ----------------------------
# USERS
# ----------------------------
def get_user_by_username(username):
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM users WHERE username=%s", (username,))
    user = cursor.fetchone()
    cursor.close()
    return user


def get_user_by_google_id(google_id):
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM users WHERE google_id=%s", (google_id,))
    user = cursor.fetchone()
    cursor.close()
    return user


def insert_google_user(name, email, google_id, picture):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO users (username, email, google_id, picture)
        VALUES (%s,%s,%s,%s)
    """, (name, email, google_id, picture))
    mysql.connection.commit()
    cursor.close()


# ----------------------------
# QUESTIONS
# ----------------------------
def get_questions(category_id, difficulty=None, level=None):
    cursor = mysql.connection.cursor()

    if difficulty and level:
        cursor.execute("""
            SELECT q.*, c.name AS category_name
            FROM questions q
            JOIN categories c ON q.category_id = c.id
            WHERE q.category_id=%s AND q.difficulty=%s AND q.level=%s
            ORDER BY RAND()
            LIMIT 10
        """, (category_id, difficulty, level))
    elif difficulty:
        cursor.execute("""
            SELECT q.*, c.name AS category_name
            FROM questions q
            JOIN categories c ON q.category_id = c.id
            WHERE q.category_id=%s AND q.difficulty=%s
            ORDER BY RAND()
            LIMIT 10
        """, (category_id, difficulty))
    else:
        cursor.execute("""
            SELECT q.*, c.name AS category_name
            FROM questions q
            JOIN categories c ON q.category_id = c.id
            WHERE q.category_id=%s
            ORDER BY RAND()
            LIMIT 10
        """, (category_id,))

    data = cursor.fetchall()
    cursor.close()
    return data


# ----------------------------
# QUIZ COMPLETION
# ----------------------------
def save_quiz_completion(data):
    cursor = mysql.connection.cursor()

    cursor.execute("""
        INSERT INTO quiz_completions
        (user_id, user_email, category_id, difficulty, level,
         score, total_questions, percentage, level_completed)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        ON DUPLICATE KEY UPDATE
        score=%s, total_questions=%s, percentage=%s, completed_at=NOW()
    """, (
        data["user_id"], data["email"], data["category_id"],
        data["difficulty"], data["level"],
        data["score"], data["total"], data["percentage"],
        data["percentage"] == 100,
        data["score"], data["total"], data["percentage"]
    ))

    mysql.connection.commit()
    cursor.close()
