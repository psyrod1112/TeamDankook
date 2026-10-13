from fastapi import FastAPI, HTTPException # Depends, Header
import os
from dotenv import load_dotenv
import sqlite3
import httpx

load_dotenv()

app = FastAPI(title="TeamDankook API", version="1.0.0")

SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError("SECRET_KEY가 .env에 없습니다")

PORTAL_URL = os.getenv("PORTAL_URL")
if not PORTAL_URL:
    raise RuntimeError("포탈 Url이 없습니다.")

PORTAL_API_KEY = os.getenv("PORTAL_API_KEY")
if not PORTAL_API_KEY:
    raise RuntimeError("포탈 API 키가 없습니다.")

# DB 초기설정

DB_PATH = "data/teamdankook.db"
os.makedirs("data", exist_ok=True)
# 로컬에서 uvicorn으로 켤 때 data/ 폴더가 없으면 만들기

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    return conn

def init_db():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            login_id TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            role TEXT NOT NULL CHECK (role IN ('student', 'professor')),
            department TEXT NOT NULL,
            consent_at TEXT
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS courses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            portal_id TEXT UNIQUE NOT NULL,
            code TEXT NOT NULL,
            title TEXT NOT NULL,
            professor_id INTEGER NOT NULL,
            schedule TEXT NOT NULL,
            start_date TEXT NOT NULL,
            has_team_project INTEGER NOT NULL DEFAULT 0,
            peer_review_open INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (professor_id) REFERENCES users(id)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS enrollments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            course_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
            UNIQUE(user_id, course_id)
        ) 
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS teams (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            portal_id TEXT UNIQUE NOT NULL,
            course_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
            UNIQUE(course_id, name)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS team_members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            team_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            course_id INTEGER NOT NULL,
            FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
            UNIQUE(team_id, user_id),
            UNIQUE(course_id, user_id)
        )
    """)

    conn.commit()
    conn.close()

@app.on_event("startup")
def startup_event():
    init_db()

# 포털 서버 관련
def fetch_from_portal(path: str):
    try:
        res = httpx.get(f"{PORTAL_URL}{path}",
                        headers={"X-API-Key": PORTAL_API_KEY},
                        timeout=5)
    except httpx.RequestError:          # 연결 실패, 타임아웃 등 "응답을 못 받은" 모든 경우
        raise HTTPException(status_code=503, detail="포털에 연결할 수 없습니다")

    if res.status_code == 404:
        raise HTTPException(status_code=404, detail="포털에 없는 사용자입니다")
    if res.status_code != 200:
        raise HTTPException(status_code=502, detail="포털 응답 오류")   # 배경 지식 3) 표 참고
    return res.json()


def upsert_user(cursor, login_id, name, role, department):
    cursor.execute("""
        INSERT INTO users (login_id, name, role, department) VALUES (?, ?, ?, ?)
        ON CONFLICT(login_id) DO UPDATE SET
            name = excluded.name,
            role = excluded.role,
            department = excluded.department
    """, (login_id, name, role, department))
    cursor.execute("SELECT id FROM users WHERE login_id = ?", (login_id,))
    return cursor.fetchone()[0]

def upsert_course(cursor, course, professor_id):
    cursor.execute("""
        INSERT INTO courses (portal_id, code, title, professor_id, schedule, start_date, has_team_project) VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(portal_id) DO UPDATE SET
            portal_id = excluded.portal_id,
            code = excluded.code,
            title = excluded.title,
            professor_id = excluded.professor_id,
            schedule = excluded.schedule,
            start_date = excluded.start_date,
            has_team_project = excluded.has_team_project            
    """, (course["course_id"], course["code"], course["title"], professor_id, course["schedule"], course["start_date"], course["has_team_project"]))
    cursor.execute("SELECT id FROM courses WHERE portal_id = ?", (course["course_id"],))
    return cursor.fetchone()[0]

def upsert_team(cursor, team, course_id):
    cursor.execute("""
        INSERT INTO teams (portal_id, course_id, name) VALUES (?, ?, ?)
        ON CONFLICT(portal_id) DO UPDATE SET
            portal_id = excluded.portal_id,
            course_id = excluded.course_id,
            name = excluded.name          
    """, (team["team_id"], course_id, team["name"]))
    cursor.execute("SELECT id FROM teams WHERE portal_id = ?", (team["team_id"],))
    return cursor.fetchone()[0]

def sync_student(login_id):
    
    me = fetch_from_portal(f"/portal/people/{login_id}")
    courses = fetch_from_portal(f"/portal/students/{login_id}/courses")
    try: 
        conn = get_db()
        cursor = conn.cursor()
        my_id = upsert_user(cursor, me["login_id"], me["name"], me["role"], me["department"])
        for course in courses:
            prof = course["professor"]
            prof_id = upsert_user(cursor, prof["login_id"], prof["name"], "professor", prof["department"])
            course_id = upsert_course(cursor, course, prof_id)
            cursor.execute("INSERT OR IGNORE INTO enrollments (user_id, course_id) VALUES (?, ?)", (my_id, course_id))
            team = course["team"]
            if team:
                team_id = upsert_team(cursor, team, course_id)
                for member in team["members"]:
                    member_id = upsert_user(cursor, member["login_id"], member["name"], "student", member["department"])
                    cursor.execute("INSERT OR IGNORE INTO team_members (team_id, user_id, course_id) VALUES (?, ?, ?)", (team_id, member_id, course_id))

        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"sync 실패 {login_id}: {e!r}")
        raise HTTPException(status_code=500, detail=f"sync_student 중 오류 발생")
    finally:
        conn.close()

@app.post("/api/dev/sync/{login_id}")
def dev_sync(login_id: str):
    sync_student(login_id)
    return {"message": "동기화 완료", "login_id": login_id}


@app.get("/api/health")
def health_check():
    return {"status": "ok!"}