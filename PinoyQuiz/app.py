from flask import Flask, render_template, request, redirect, url_for, session, flash
import pymysql
pymysql.install_as_MySQLdb()
from werkzeug.security import generate_password_hash
from flask_mysqldb import MySQL
import json
import traceback
import os
from models import init_db, get_user_by_username, get_user_by_google_id, insert_google_user, get_questions, save_quiz_completion
from forms import login_form, signup_form, question_form
import re

# ----------------------------
# GOOGLE OAUTH IMPORTS
# ----------------------------
from google.oauth2 import id_token
from google_auth_oauthlib.flow import Flow
import google.auth.transport.requests

app = Flask(__name__)
app.secret_key = "secretkey123"

os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"  # allow http for localhost

# ----------------------------
# MYSQL CONFIGURATION
# ----------------------------
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'pinoy_quiz'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)

# ----------------------------
# GOOGLE OAUTH SETUP
# ----------------------------
flow = Flow.from_client_secrets_file(
    "client_secret.json",
    scopes=[
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile",
        "openid"
    ],
    redirect_uri="http://localhost:5000/google/callback"
)



# ----------------------------
# Helper utilities
# ----------------------------
def normalize_difficulty_and_level(difficulty, level):
    """
    Normalize difficulty and level:
    - difficulty: keep as string ('' if None)
    - level: for easy/medium -> string '1','2'... ; for hard -> None
    """
    if difficulty is None:
        difficulty = ""
    else:
        difficulty = str(difficulty)

    if difficulty in ("easy", "medium"):
        # default to "1" if level missing or invalid
        if not level or not str(level).isdigit():
            level = "1"
        else:
            level = str(level)
    else:
        level = None

    return difficulty, level


# ----------------------------
# ROUTES (STATIC PAGES)
# ----------------------------
@app.route("/")
def home():
    return render_template("home.html")


@app.route("/about")
def about():
    return render_template("about.html")


@app.route("/leaderboard")
def leaderboard():
    category = request.args.get("category", "All")
    difficulty = request.args.get("difficulty", "all")
    user_id = session.get("user_id")

    cursor = mysql.connection.cursor()

    # ----------------------------
    # CATEGORY FILTER
    # ----------------------------
    if category == "All":
        category_sql = ""
        category_params = ()
    else:
        category_sql = "AND c.name = %s"
        category_params = (category,)

    # ----------------------------
    # ALL DIFFICULTIES
    # ----------------------------
    if difficulty == "all":
        query = f"""
            SELECT
                t.user_id,
                t.player_name,
                t.category_name,
                SUM(t.score) AS total_score,
                SUM(t.total_questions) AS total_questions,
                ROUND((SUM(t.score)/NULLIF(SUM(t.total_questions),0))*100) AS rate,
                MAX(t.completed_at) AS date
            FROM (

                -- QUIZ SCORES
                SELECT
                    u.id AS user_id,
                    u.username AS player_name,
                    c.name AS category_name,
                    qc.score,
                    qc.total_questions,
                    qc.completed_at
                FROM quiz_completions qc
                JOIN users u ON u.id = qc.user_id
                JOIN categories c ON c.id = qc.category_id
                WHERE 1=1
                {category_sql}

                UNION ALL

                -- HARD PUZZLE SCORES
                SELECT
                    u.id AS user_id,
                    u.username AS player_name,
                    c.name AS category_name,
                    l.score,
                    10 AS total_questions, -- fixed base for puzzle
                    l.created_at AS completed_at
                FROM leaderboard l
                JOIN users u ON u.id = l.user_id
                JOIN categories c ON c.id = l.category_id
                WHERE l.difficulty = 'hard'
                {category_sql}

            ) t
            GROUP BY t.user_id, t.category_name
        """
        params = category_params + category_params

    # ----------------------------
    # SPECIFIC DIFFICULTY
    # ----------------------------
    else:
        query = f"""
            SELECT
                t.user_id,
                t.player_name,
                t.category_name,
                t.difficulty,
                SUM(t.score) AS total_score,
                SUM(t.total_questions) AS total_questions,
                ROUND((SUM(t.score)/NULLIF(SUM(t.total_questions),0))*100) AS rate,
                MAX(t.completed_at) AS date
            FROM (

                -- QUIZ SCORES
                SELECT
                    u.id AS user_id,
                    u.username AS player_name,
                    c.name AS category_name,
                    qc.difficulty,
                    qc.score,
                    qc.total_questions,
                    qc.completed_at
                FROM quiz_completions qc
                JOIN users u ON u.id = qc.user_id
                JOIN categories c ON c.id = qc.category_id
                WHERE qc.difficulty = %s
                {category_sql}

                UNION ALL

                -- HARD PUZZLE SCORES
                SELECT
                    u.id AS user_id,
                    u.username AS player_name,
                    c.name AS category_name,
                    'hard' AS difficulty,
                    l.score,
                    10 AS total_questions,
                    l.created_at AS completed_at
                FROM leaderboard l
                JOIN users u ON u.id = l.user_id
                JOIN categories c ON c.id = l.category_id
                WHERE l.difficulty = 'hard'
                {category_sql}

            ) t
            GROUP BY t.user_id, t.category_name, t.difficulty
        """
        params = (difficulty,) + category_params + category_params

    # ----------------------------
    # EXECUTE
    # ----------------------------
    cursor.execute(query, params)
    leaderboard_data = cursor.fetchall()
    cursor.close()

    # 🔥 SORT BY SCORE
    leaderboard_data = sorted(
        leaderboard_data,
        key=lambda x: x["total_score"],
        reverse=True
    )

    return render_template(
        "leaderboard.html",
        leaderboard=leaderboard_data,
        active_category=category,
        active_difficulty=difficulty,
        current_user_id=user_id
    )










@app.route("/quiz")
def quiz():
    return render_template("quiz.html")


# ----------------------------
# GOOGLE LOGIN — START
# ----------------------------
@app.route("/google/login")
def google_login():
    auth_url, _ = flow.authorization_url()
    return redirect(auth_url)


@app.route("/google/callback")
def google_callback():
    flow.fetch_token(authorization_response=request.url)

    credentials = flow.credentials
    request_session = google.auth.transport.requests.Request()

    user_info = id_token.verify_oauth2_token(
        credentials._id_token,
        request_session,
        flow.client_config["client_id"]
    )

    google_id = user_info["sub"]
    email = user_info["email"]
    name = user_info["name"]
    picture = user_info.get("picture", "")

    # Store in session
    session["role"] = "user"
    session["username"] = name
    session["email"] = email
    session["google_id"] = google_id
    session["picture"] = picture

    # Save user in MySQL if not exists
    cursor = mysql.connection.cursor()

    cursor.execute("SELECT * FROM users WHERE google_id=%s", (google_id,))
    existing = cursor.fetchone()

    if not existing:
        cursor.execute(
            "INSERT INTO users (username, email, google_id, picture) VALUES (%s, %s, %s, %s)",
            (name, email, google_id, picture)
        )
        mysql.connection.commit()
        cursor.execute("SELECT * FROM users WHERE google_id=%s", (google_id,))
        existing = cursor.fetchone()

    # Store user_id in session
    if existing:
        session["user_id"] = existing["id"]

    cursor.close()

    return redirect(url_for("user_dashboard"))


# ----------------------------
# NORMAL LOGIN
# ----------------------------
@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        cursor = mysql.connection.cursor()

        # 1️⃣ CHECK ADMIN TABLE
        cursor.execute("SELECT * FROM admin WHERE username=%s AND password=%s",
                       (username, password))
        admin = cursor.fetchone()

        if admin:
            session["role"] = "admin"
            session["username"] = admin["username"]
            return redirect(url_for("admin_dashboard"))

        # 2️⃣ CHECK USERS TABLE
        cursor.execute("SELECT * FROM users WHERE username=%s AND password=%s",
                       (username, password))
        user = cursor.fetchone()
        cursor.close()

        if user:
            session["role"] = "user"
            session["username"] = user["username"]
            session["user_id"] = user["id"]
            session["email"] = user.get("email")
            session["picture"] = user.get("picture")
            return redirect(url_for("user_dashboard"))

        flash("Invalid username or password")

    return render_template("login.html")


# ----------------------------
# SIGNUP
# ----------------------------
@app.route("/signup", methods=["GET", "POST"])
def signup():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        # Server-side password validation
        if len(password) < 8 or not re.search(r"[A-Z]", password) or not re.search(r"\d", password):
            flash("Password must be at least 8 characters long, include one uppercase letter and one number.")
            return redirect(url_for("signup"))

        cursor = mysql.connection.cursor()

        # Check if username already exists
        cursor.execute("SELECT * FROM users WHERE username=%s", (username,))
        existing = cursor.fetchone()
        if existing:
            flash("Username already taken!")
            cursor.close()
            return redirect(url_for("signup"))

        # Hash the password before saving
        hashed_password = generate_password_hash(password)

        # Save user to database
        cursor.execute(
            "INSERT INTO users (username, password) VALUES (%s, %s)",
            (username, hashed_password)
        )
        mysql.connection.commit()
        cursor.close()

        flash("Account created successfully!")
        return redirect(url_for("login"))

    return render_template("signup.html")


# ----------------------------
# USER DASHBOARD
# ----------------------------
@app.route("/user/dashboard")
def user_dashboard():
    if session.get("role") != "user":
        return redirect(url_for("login"))

    # Build user data object for template
    user = {
        "username": session.get("username", "User"),
        "email": session.get("email", None),
        "picture": session.get("picture", None),
        "auth_method": "google" if session.get("google_id") else "local"
    }

    return render_template("user_dashboard.html", user=user)


# ----------------------------
# ADMIN DASHBOARD
# ----------------------------
@app.route("/admin/dashboard")
def admin_dashboard():
    if session.get("role") != "admin":
        return redirect(url_for("login"))
    return render_template("admin/admin_dashboard.html")


@app.route("/quiz_dashboard")
def quiz_dashboard():
    if session.get("role") != "user":
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor()

    cursor.execute("SELECT * FROM questions WHERE category_id = 1")
    history = cursor.fetchall()

    cursor.execute("SELECT * FROM questions WHERE category_id = 2")
    culture = cursor.fetchall()

    cursor.execute("SELECT * FROM questions WHERE category_id = 3")
    geography = cursor.fetchall()

    # Get user completions
    user_id = session.get("user_id")
    completions = {}  # Initialize as empty dict

    if user_id:
        try:
            # Check if table exists first
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM information_schema.tables 
                WHERE table_schema = DATABASE() 
                AND table_name = 'quiz_completions'
            """)
            result = cursor.fetchone()
            table_exists = result and result.get('count', 0) > 0

            if table_exists:
                cursor.execute("""
                    SELECT category_id, difficulty, level, MAX(percentage) as best_score, 
                           COUNT(*) as attempts, MAX(completed_at) as last_completed
                    FROM quiz_completions
                    WHERE user_id = %s
                    GROUP BY category_id, difficulty, level
                """, (user_id,))

                completion_records = cursor.fetchall()

                for record in completion_records:
                    # normalize values to strings where appropriate
                    raw_level = record.get('level')
                    level_key = str(raw_level) if raw_level is not None and raw_level != "" else ''
                    difficulty_key = record.get('difficulty') or ''
                    category_id_key = record.get('category_id') or 0

                    # Create a unique key for each level
                    if level_key:
                        key = f"{category_id_key}_{difficulty_key}_{level_key}"
                    else:
                        key = f"{category_id_key}_{difficulty_key}"

                    best_score = record.get('best_score')
                    if best_score is not None:
                        try:
                            best_score = float(best_score)
                        except (ValueError, TypeError):
                            best_score = 0
                    else:
                        best_score = 0

                    completions[key] = {
                        'completed': True,
                        'best_score': best_score,
                        'attempts': record.get('attempts', 0),
                        'last_completed': record.get('last_completed')
                    }
        except Exception as e:
            print(f"Error fetching completions: {e}")
            traceback.print_exc()

    cursor.close()

    # Convert completions to JSON string safely
    try:
        completions_json = json.dumps(completions, default=str)
    except Exception as e:
        print(f"Error converting completions to JSON: {e}")
        completions_json = "{}"

    return render_template(
        "quiz_dashboard.html",
        history=history,
        culture=culture,
        geography=geography,
        completions=completions,
        completions_json=completions_json,
        current_category=1
    )


@app.route("/reviewer")
def reviewer():
    return render_template("reviewer.html")


@app.route("/start_quiz/<int:category_id>")
def start_quiz(category_id):
    if session.get("role") != "user":
        return redirect(url_for("login"))

    # Get difficulty and level parameters
    difficulty = request.args.get('difficulty', None)
    level = request.args.get('level', None)

    # Normalize difficulty & level for storage/logic consistency
    difficulty_norm, level_norm = normalize_difficulty_and_level(difficulty, level)

    cursor = mysql.connection.cursor()

    # ----------------------------
    # LEVEL LOCKING BACKEND CHECK (IMPROVED)
    # ----------------------------
    if difficulty_norm in ["easy", "medium"] and level_norm:
        try:
            level_int = int(level_norm)
            prev_level = level_int - 1
            if level_int > 1:
                prev_level_str = str(prev_level)

                cursor.execute("""
                    SELECT COUNT(*) AS completed
                    FROM quiz_completions
                    WHERE user_id = %s 
                      AND category_id = %s 
                      AND difficulty = %s 
                      AND level = %s
                """, (session.get("user_id"), category_id, difficulty_norm, prev_level_str))

                result = cursor.fetchone()
                completed_count = result.get("completed", 0) if result else 0

                if completed_count == 0:
                    flash("You must complete previous levels first.")
                    cursor.close()
                    return redirect(url_for("quiz_dashboard"))
        except Exception as e:
            print("Level lock check error:", e)
            traceback.print_exc()

    try:
        # Build query based on category, difficulty, and level
        if difficulty_norm:
            if level_norm:
                # For Easy or Medium difficulty with level, filter by difficulty and level
                # Check if columns exist first
                cursor.execute("""
                    SELECT COLUMN_NAME 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = DATABASE() 
                    AND TABLE_NAME = 'questions' 
                    AND COLUMN_NAME IN ('difficulty', 'level')
                """)
                columns = [row['COLUMN_NAME'] for row in cursor.fetchall()]

                if 'difficulty' in columns and 'level' in columns:
                    cursor.execute("""
                        SELECT q.*, c.name AS category_name
                        FROM questions q
                        JOIN categories c ON q.category_id = c.id
                        WHERE q.category_id = %s AND q.difficulty = %s AND q.level = %s
                        ORDER BY RAND()
                        LIMIT 10
                    """, (category_id, difficulty_norm, level_norm))
                else:
                    # If columns don't exist, get questions without filtering by difficulty/level
                    cursor.execute("""
                        SELECT q.*, c.name AS category_name
                        FROM questions q
                        JOIN categories c ON q.category_id = c.id
                        WHERE q.category_id = %s
                        ORDER BY RAND()
                        LIMIT 10
                    """, (category_id,))
            else:
                # For Hard or difficulty without level
                cursor.execute("""
                    SELECT COLUMN_NAME 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = DATABASE() 
                    AND TABLE_NAME = 'questions' 
                    AND COLUMN_NAME = 'difficulty'
                """)
                has_difficulty = len(cursor.fetchall()) > 0

                if has_difficulty:
                    cursor.execute("""
                        SELECT q.*, c.name AS category_name
                        FROM questions q
                        JOIN categories c ON q.category_id = c.id
                        WHERE q.category_id = %s AND q.difficulty = %s
                        ORDER BY RAND()
                        LIMIT 10
                    """, (category_id, difficulty_norm))
                else:
                    cursor.execute("""
                        SELECT q.*, c.name AS category_name
                        FROM questions q
                        JOIN categories c ON q.category_id = c.id
                        WHERE q.category_id = %s
                        ORDER BY RAND()
                        LIMIT 10
                    """, (category_id,))
        else:
            # If no difficulty specified, get random questions
            cursor.execute("""
                SELECT q.*, c.name AS category_name
                FROM questions q
                JOIN categories c ON q.category_id = c.id
                WHERE q.category_id = %s
                ORDER BY RAND()
                LIMIT 10
            """, (category_id,))

        questions = cursor.fetchall()

        # Store quiz info in session for later use in submit_quiz
        # Save normalized difficulty/level so submit_quiz receives consistent values
        session['current_quiz'] = {
            'category_id': category_id,
            'difficulty': difficulty_norm,
            'level': level_norm
        }

        # Debug: Print questions to console (remove in production)
        print(f"Found {len(questions)} questions")
        for q in questions:
            print(f"Question: {q.get('question', 'N/A')}")

    except Exception as e:
        print(f"Error fetching questions: {e}")
        traceback.print_exc()
        questions = []
    finally:
        cursor.close()

    return render_template("take_quiz.html", questions=questions)


@app.route("/submit_quiz", methods=["POST"])
def submit_quiz():
    if session.get("role") != "user":
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor()

    score = 0
    total = 0
    results = []
    completion_saved = False

    # Prevent UnboundLocalError
    unlock_success = False
    next_level = None

    # Load quiz session info
    quiz_info = session.get('current_quiz', {})
    category_id = quiz_info.get('category_id')
    difficulty = quiz_info.get('difficulty')
    level = quiz_info.get('level')

    # Normalize difficulty/level
    difficulty, level = normalize_difficulty_and_level(difficulty, level)

    user_email = session.get("email")
    username = session.get("username")

    try:
        # ---------------------------
        # GET USER ID
        # ---------------------------
        user_id = session.get("user_id")

        if not user_id:
            if user_email:
                cursor.execute("SELECT id FROM users WHERE email=%s", (user_email,))
                user = cursor.fetchone()
                if user:
                    user_id = user["id"]
                    session["user_id"] = user_id
            elif username:
                cursor.execute("SELECT id FROM users WHERE username=%s", (username,))
                user = cursor.fetchone()
                if user:
                    user_id = user["id"]
                    session["user_id"] = user_id

        # ---------------------------
        # PROCESS ANSWERS
        # ---------------------------
        form_data = request.form.to_dict()
        question_ids = set()

        for key in form_data:
            if key.startswith("question_") or key.startswith("correct_"):
                try:
                    question_ids.add(int(key.split("_")[1]))
                except:
                    pass

        for question_id in question_ids:
            user_answer = form_data.get(f"question_{question_id}", "").strip()
            correct_answer = form_data.get(f"correct_{question_id}", "")

            if not correct_answer:
                continue

            total += 1

            cursor.execute("SELECT * FROM questions WHERE id=%s", (question_id,))
            question = cursor.fetchone()

            is_correct = (user_answer.upper() == correct_answer.upper()) if user_answer else False
            if is_correct:
                score += 1

            results.append({
                "question": question["question"] if question else "N/A",
                "user_answer": user_answer if user_answer else "No Answer",
                "correct_answer": correct_answer,
                "is_correct": is_correct
            })

        # ---------------------------
        # CALCULATE PERCENTAGE
        # ---------------------------
        percentage = (score / total * 100) if total > 0 else 0

        # ---------------------------
        # SAVE QUIZ COMPLETION
        # ---------------------------
        cursor.execute("""
            SELECT id FROM quiz_completions
            WHERE user_id=%s AND category_id=%s AND difficulty=%s AND level <=> %s
        """, (user_id, category_id, difficulty, level))
        
        existing = cursor.fetchone()

        if existing:
            cursor.execute("""
                UPDATE quiz_completions
                SET score=%s, total_questions=%s, percentage=%s, completed_at=NOW(),
                    level_completed=%s
                WHERE id=%s
            """, (score, total, percentage, (percentage == 100), existing["id"]))
        else:
            cursor.execute("""
                INSERT INTO quiz_completions
                (user_id, user_email, category_id, difficulty, level,
                 score, total_questions, percentage, level_completed)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                user_id, user_email, category_id, difficulty, level,
                score, total, percentage, (percentage == 100)
            ))

        mysql.connection.commit()
        completion_saved = True

        # ---------------------------------------------------------
        # 🔥 AUTO-UNLOCK NEXT LEVEL IF PERFECT SCORE
        # ---------------------------------------------------------
        if difficulty in ["easy", "medium"] and level and percentage == 100:
            next_level = str(int(level) + 1)

            cursor.execute("""
                INSERT INTO user_quiz_progress (user_id, category_id, difficulty, level, unlocked)
                VALUES (%s, %s, %s, %s, 1)
                ON DUPLICATE KEY UPDATE unlocked = 1
            """, (user_id, category_id, difficulty, next_level))

            mysql.connection.commit()
            unlock_success = True

    except Exception as e:
        print("Submit quiz error:", e)
        flash("Error processing quiz")
    finally:
        cursor.close()

    # Clear quiz session data
    session.pop("current_quiz", None)

    # ---------------------------
    # RETURN RESULTS PAGE
    # ---------------------------
    return render_template(
        "quiz_results.html",
        score=score,
        total=total,
        percentage=percentage,
        results=results,
        category_id=category_id,
        difficulty=difficulty,
        level=level,
        completion_saved=completion_saved,
        unlock_success=unlock_success,
        next_level=next_level
    )




@app.route('/reset_progress')
def reset_progress():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']

    cursor = mysql.connection.cursor()
    # if user_quiz_progress table not present this will error; you may want to check for existence
    try:
        cursor.execute("DELETE FROM user_quiz_progress WHERE user_id=%s", (user_id,))
        mysql.connection.commit()
    except Exception as e:
        print("Error resetting progress:", e)
    finally:
        cursor.close()

    flash("All levels have been reset! You can now retake all quizzes.")
    return redirect(url_for('user_dashboard'))


# ----------------------------
# UNLOCK NEXT LEVEL ROUTE
# ----------------------------
@app.route("/unlock_next_level")
def unlock_next_level():
    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    cursor = mysql.connection.cursor()

    # Get last completion for user (so UI can decide)
    cursor.execute("""
        SELECT category_id, difficulty, level
        FROM quiz_completions
        WHERE user_id = %s
        ORDER BY completed_at DESC
        LIMIT 1
    """, (user_id,))

    last = cursor.fetchone()
    cursor.close()

    # We won't insert any fake completion here. The UI will use real data or session['unlock_next'] as needed.
    flash("Next level unlocked! You may now proceed to the next level.", "success")
    return redirect(url_for("quiz_dashboard"))


# ----------------------------
# LOGOUT
# ----------------------------
@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("home"))


@app.route("/admin")
def admin_home():
    if session.get("role") != "admin":
        return redirect(url_for("login"))
    return render_template("admin/admin_dashboard.html")


@app.route("/admin/questions")
def admin_questions():
    if session.get("role") != "admin":
        return redirect(url_for("login"))

    category = request.args.get("category", "All")
    difficulty = request.args.get("difficulty", "all")

    cursor = mysql.connection.cursor()

    # Fetch for tabs
    cursor.execute("SELECT * FROM categories")
    categories = cursor.fetchall()

    # Base SQL
    sql = """
        SELECT q.*, c.name AS category_name
        FROM questions q
        JOIN categories c ON q.category_id = c.id
        WHERE 1=1
    """
    params = []

    # Category filter
    if category != "All":
        sql += " AND c.name = %s"
        params.append(category)

    # Difficulty filter
    if difficulty != "all":
        sql += " AND q.difficulty = %s"
        params.append(difficulty)

    sql += " ORDER BY q.id DESC"

    cursor.execute(sql, params)
    questions = cursor.fetchall()
    cursor.close()

    return render_template(
        "admin/admin_questions.html",
        questions=questions,
        categories=categories,
        active_category=category,
        active_difficulty=difficulty
    )



@app.route("/admin/question/add", methods=["GET", "POST"])
def admin_add_question():
    if session.get("role") != "admin":
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor()

    if request.method == "POST":
        category_id = request.form["category_id"]
        difficulty = request.form["difficulty"]
        level = request.form.get("level")
        question = request.form["question"]
        option_a = request.form["option_a"]
        option_b = request.form["option_b"]
        option_c = request.form["option_c"]
        option_d = request.form["option_d"]
        correct = request.form["correct"]

        cursor.execute("""
            INSERT INTO questions
            (category_id, difficulty, level, question, option_a, option_b, option_c, option_d, correct_option)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (category_id, difficulty, level, question, option_a, option_b, option_c, option_d, correct))

        mysql.connection.commit()
        cursor.close()

        flash("Question added successfully!", "success")
        return redirect(url_for("admin_questions"))

    cursor.execute("SELECT * FROM categories")
    categories = cursor.fetchall()
    cursor.close()

    return render_template("admin/admin_add_question.html", categories=categories)


@app.route("/admin/question/edit/<int:id>", methods=["GET", "POST"])
def admin_edit_question(id):
    if session.get("role") != "admin":
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor()

    if request.method == "POST":
        category_id = request.form["category_id"]
        difficulty = request.form["difficulty"]
        level = request.form.get("level")
        question = request.form["question"]
        option_a = request.form["option_a"]
        option_b = request.form["option_b"]
        option_c = request.form["option_c"]
        option_d = request.form["option_d"]
        correct = request.form["correct"]

        cursor.execute("""
            UPDATE questions SET 
            category_id=%s, difficulty=%s, level=%s,
            question=%s, option_a=%s, option_b=%s, option_c=%s, option_d=%s,
            correct_option=%s
            WHERE id=%s
        """, (category_id, difficulty, level, question, option_a, option_b, option_c, option_d, correct, id))

        mysql.connection.commit()
        cursor.close()

        flash("Question updated!", "success")
        return redirect(url_for("admin_questions"))

    cursor.execute("SELECT * FROM questions WHERE id=%s", (id,))
    question = cursor.fetchone()

    cursor.execute("SELECT * FROM categories")
    categories = cursor.fetchall()

    cursor.close()

    return render_template("admin/admin_edit_question.html", question=question, categories=categories)


@app.route("/admin/question/delete/<int:id>")
def admin_delete_question(id):
    if session.get("role") != "admin":
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM questions WHERE id=%s", (id,))
    mysql.connection.commit()
    cursor.close()

    flash("Question deleted!", "danger")
    return redirect(url_for("admin_questions"))


@app.route("/admin/users")
def admin_users():
    if session.get("role") != "admin":
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM users ORDER BY id DESC")
    users = cursor.fetchall()
    cursor.close()

    return render_template("admin/admin_users.html", users=users)


@app.route("/admin/user/delete/<int:id>")
def admin_delete_user(id):
    if session.get("role") != "admin":
        return redirect(url_for("login"))

    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM users WHERE id=%s", (id,))
    mysql.connection.commit()
    cursor.close()

    flash("User deleted!", "danger")
    return redirect(url_for("admin_users"))


@app.route("/admin/leaderboard")
def admin_leaderboard():
    if session.get("role") != "admin":
        return redirect(url_for("login"))

    category = request.args.get("category", "All")
    difficulty = request.args.get("difficulty", "all")

    cursor = mysql.connection.cursor()

    # ------------------
    # CATEGORY FILTER
    # ------------------
    if category == "All":
        category_sql = ""
        category_params = ()
    else:
        category_sql = "AND c.name = %s"
        category_params = (category,)

    # ------------------
    # DIFFICULTY = ALL
    # ------------------
    if difficulty == "all":

        query = f"""
            SELECT
                t.username,
                t.category,
                SUM(t.score) AS total_score,
                SUM(t.total_questions) AS total_questions,
                ROUND((SUM(t.score) / NULLIF(SUM(t.total_questions), 0)) * 100) AS percentage,
                MAX(t.completed_at) AS last_date
            FROM (

                -- QUIZ SCORES
                SELECT
                    u.username,
                    c.name AS category,
                    qc.score,
                    qc.total_questions,
                    qc.completed_at
                FROM quiz_completions qc
                JOIN users u ON u.id = qc.user_id
                JOIN categories c ON c.id = qc.category_id
                WHERE 1=1
                {category_sql}

                UNION ALL

                -- HARD PUZZLE SCORES
                SELECT
                    u.username,
                    c.name AS category,
                    l.score,
                    10 AS total_questions,
                    l.created_at AS completed_at
                FROM leaderboard l
                JOIN users u ON u.id = l.user_id
                JOIN categories c ON c.id = l.category_id
                WHERE l.difficulty = 'hard'
                {category_sql}

            ) t
            GROUP BY t.username, t.category
        """

        params = category_params + category_params

    # ------------------
    # DIFFICULTY = EASY / MEDIUM / HARD
    # ------------------
    else:

        query = f"""
            SELECT
                t.username,
                t.category,
                t.difficulty,
                SUM(t.score) AS total_score,
                SUM(t.total_questions) AS total_questions,
                ROUND((SUM(t.score) / NULLIF(SUM(t.total_questions), 0)) * 100) AS percentage,
                MAX(t.completed_at) AS last_date
            FROM (

                -- QUIZ SCORES
                SELECT
                    u.username,
                    c.name AS category,
                    qc.difficulty,
                    qc.score,
                    qc.total_questions,
                    qc.completed_at
                FROM quiz_completions qc
                JOIN users u ON u.id = qc.user_id
                JOIN categories c ON c.id = qc.category_id
                WHERE qc.difficulty = %s
                {category_sql}

                UNION ALL

                -- HARD PUZZLE SCORES
                SELECT
                    u.username,
                    c.name AS category,
                    'hard' AS difficulty,
                    l.score,
                    10 AS total_questions,
                    l.created_at AS completed_at
                FROM leaderboard l
                JOIN users u ON u.id = l.user_id
                JOIN categories c ON c.id = l.category_id
                WHERE l.difficulty = 'hard'
                {category_sql}

            ) t
            GROUP BY t.username, t.category, t.difficulty
        """

        params = (difficulty,) + category_params + category_params

    # ------------------
    # EXECUTE QUERY
    # ------------------
    cursor.execute(query, params)
    leaderboard = cursor.fetchall()
    cursor.close()

    # 🔥 SORT BY HIGHEST SCORE
    leaderboard = sorted(
        leaderboard,
        key=lambda x: x["total_score"],
        reverse=True
    )

    return render_template(
        "admin/admin_leaderboard.html",
        leaderboard=leaderboard,
        active_category=category,
        active_difficulty=difficulty
    )



@app.route('/admin/logout')
def admin_logout():
    session.clear()
    return render_template('logout.html')

@app.route("/hard_game")
def hard_game():
    if session.get("role") != "user":
        return redirect(url_for("login"))

    category_id = request.args.get("category", type=int, default=1)
    return render_template("hard_game.html", category_id=category_id)


@app.route("/save_hard_score", methods=["POST"])
def save_hard_score():
    if session.get("role") != "user":
        return {"success": False}, 401

    data = request.get_json()
    new_score = int(data.get("score", 0))
    category_id = int(data.get("category"))

    user_id = session.get("user_id")
    user_email = session.get("email")

    TOTAL_QUESTIONS = 10

    cursor = mysql.connection.cursor()

    # ----------------------------------
    # 1️⃣ GET BEST SCORE SO FAR
    # ----------------------------------
    cursor.execute("""
        SELECT MAX(score) AS best_score
        FROM quiz_completions
        WHERE user_id = %s
          AND category_id = %s
          AND difficulty = 'hard'
    """, (user_id, category_id))

    row = cursor.fetchone()
    best_score = row["best_score"] if row and row["best_score"] else 0

    # ----------------------------------
    # 2️⃣ CALCULATE DIFFERENCE
    # ----------------------------------
    score_to_add = new_score - best_score

    if score_to_add > 0:
        # ----------------------------------
        # 3️⃣ CALCULATE PERCENTAGE
        # ----------------------------------
        percentage = round((new_score / TOTAL_QUESTIONS) * 100)

        # ----------------------------------
        # 4️⃣ SAVE ONLY THE DIFFERENCE
        # ----------------------------------
        cursor.execute("""
            INSERT INTO quiz_completions 
                (user_id, user_email, category_id, difficulty, score, total_questions, percentage)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            user_id,
            user_email,
            category_id,
            "hard",
            score_to_add,          # only the added score
            TOTAL_QUESTIONS,
            percentage
        ))

        mysql.connection.commit()

    cursor.close()

    return {
        "success": True,
        "added": max(score_to_add, 0),
        "best_score": max(best_score, new_score),
        "percentage": round((max(best_score, new_score) / TOTAL_QUESTIONS) * 100)
    }





# ----------------------------
# MAIN
# ----------------------------
if __name__ == "__main__":
    app.run(debug=True)
