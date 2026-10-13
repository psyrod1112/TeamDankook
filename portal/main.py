from fastapi import FastAPI, HTTPException, Depends, Header
import os
from dotenv import load_dotenv
import sqlite3
from typing import Optional
import secrets

load_dotenv()

app = FastAPI(title="Mock Dankook Portal", version="1.0.0", docs_url=None, redoc_url=None)

PORTAL_API_KEY = os.getenv("PORTAL_API_KEY")
if not PORTAL_API_KEY:
    raise RuntimeError("PORTAL_API_KEY가 .env에 없습니다")

DB_PATH = "data/portal.db"
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
        CREATE TABLE IF NOT EXISTS people (
            login_id TEXT PRIMARY KEY NOT NULL,
            name TEXT NOT NULL,
            role TEXT NOT NULL CHECK (role IN ('student', 'professor')),
            department TEXT NOT NULL
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS courses (
            course_id TEXT PRIMARY KEY NOT NULL,
            code TEXT NOT NULL,
            title TEXT NOT NULL,
            professor_id TEXT NOT NULL,
            schedule TEXT NOT NULL,
            start_date TEXT NOT NULL,
            has_team_project INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (professor_id) REFERENCES people(login_id)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS enrollments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            login_id TEXT NOT NULL,
            course_id TEXT NOT NULL,
            FOREIGN KEY (login_id) REFERENCES people(login_id),
            FOREIGN KEY (course_id) REFERENCES courses(course_id),
            UNIQUE(login_id, course_id)
        ) 
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS teams (
            team_id TEXT PRIMARY KEY NOT NULL,
            course_id TEXT NOT NULL,
            name TEXT NOT NULL,
            FOREIGN KEY (course_id) REFERENCES courses(course_id),
            UNIQUE(course_id, name)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS team_members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            team_id TEXT NOT NULL,
            login_id TEXT NOT NULL,
            course_id TEXT NOT NULL,
            FOREIGN KEY (team_id) REFERENCES teams(team_id),
            FOREIGN KEY (login_id) REFERENCES people(login_id),
            FOREIGN KEY (course_id) REFERENCES courses(course_id),
            UNIQUE(team_id, login_id),
            UNIQUE(course_id, login_id)
        )
    """)

    conn.commit()
    conn.close()

@app.on_event("startup")
def startup_event():
    init_db()
    seed_portal_data()

def seed_portal_data():
    """서버 최초 기동 시 프론트엔드가 요구하는 기본 포털 데이터가 없으면 주입"""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM people")
    if cursor.fetchone()[0] == 0:
        SEED_PEOPLE = [  # (login_id, name, role, department)
            ("P1001", "김교수", "professor", "모바일시스템공학과"),
            ("P1002", "이교수", "professor", "컴퓨터공학과"),
            ("P1003", "박교수", "professor", "소프트웨어학과"),
            ("P1004", "최교수", "professor", "컴퓨터공학과"),
            ("P1005", "정교수", "professor", "컴퓨터공학과"),
            ("32260001", "김단국", "student", "컴퓨터공학과"),
            ("32260002", "이하늘", "student", "컴퓨터공학과"),
            ("32260003", "박서준", "student", "소프트웨어학과"),
            ("32260004", "최유나", "student", "컴퓨터공학과"),
            ("32260005", "정민호", "student", "모바일시스템공학과"),
            ("32260006", "한지우", "student", "컴퓨터공학과"),
            ("32260007", "강민수", "student", "소프트웨어학과"),
            ("32260008", "윤가은", "student", "컴퓨터공학과"),
        ]
        
        for p in SEED_PEOPLE:
            cursor.execute("""
                INSERT INTO people (login_id, name, role, department)
                VALUES (?, ?, ?, ?)
            """, p)

    cursor.execute("SELECT COUNT(*) FROM courses")
    if cursor.fetchone()[0] == 0:
        SEED_COURSES = [  # (course_id, code, title, professor_id, schedule, start_date, has_team_project)
            ("SWE-01", "SWE", "소프트웨어공학", "P1001", "월 3-4교시", "2026-09-01", 1),
            ("CAP-01", "CAP", "캡스톤디자인",   "P1002", "수 5-7교시", "2026-09-01", 1),
            ("DB-01",  "DB",  "데이터베이스",   "P1003", "화 1-2교시", "2026-09-01", 0),
            ("OS-01",  "OS",  "운영체제",       "P1004", "목 3-4교시", "2026-09-01", 0),
            ("LNX-01", "LNX", "리눅스시스템",   "P1005", "금 2-3교시", "2026-09-01", 0),
            ("AI-01",  "AI",  "인공지능개론",   "P1001", "목 5-6교시", "2026-09-01", 1),
        ]
        
        for p in SEED_COURSES:
            cursor.execute("""
                INSERT INTO courses (course_id, code, title, professor_id, schedule, start_date, has_team_project)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, p)   

    cursor.execute("SELECT COUNT(*) FROM enrollments")
    if cursor.fetchone()[0] == 0:
        SEED_ENROLLMENTS = [  # (login_id, course_id)
            ("32260001", "SWE-01"), ("32260001", "CAP-01"), ("32260001", "DB-01"),
            ("32260001", "OS-01"),  ("32260001", "LNX-01"),
            ("32260002", "SWE-01"), ("32260003", "SWE-01"), ("32260004", "SWE-01"),
            ("32260007", "SWE-01"), ("32260008", "SWE-01"),
            ("32260005", "CAP-01"), ("32260006", "CAP-01"),
            ("32260002", "AI-01"), ("32260003", "AI-01"), ("32260007", "AI-01"), ("32260008", "AI-01"),
        ]
        
        for p in SEED_ENROLLMENTS:
            cursor.execute("""
                INSERT INTO enrollments (login_id, course_id)
                VALUES (?, ?)
            """, p)   

    cursor.execute("SELECT COUNT(*) FROM teams")
    if cursor.fetchone()[0] == 0:
        SEED_TEAMS = [  # (team_id, course_id, name)
            ("SWE-01-T3", "SWE-01", "3조"),
            ("SWE-01-T1", "SWE-01", "1조"),
            ("CAP-01-T1", "CAP-01", "1조"),
            ("AI-01-T1",  "AI-01",  "1조"),
            ("AI-01-T2",  "AI-01",  "2조"),
        ]
        
        for p in SEED_TEAMS:
            cursor.execute("""
                INSERT INTO teams (team_id, course_id, name)
                VALUES (?, ?, ?)
            """, p)  

    cursor.execute("SELECT COUNT(*) FROM team_members")
    if cursor.fetchone()[0] == 0:
        SEED_TEAM_MEMBERS = [  # (team_id, login_id, course_id)
            ("SWE-01-T3", "32260001", "SWE-01"), ("SWE-01-T3", "32260002", "SWE-01"),
            ("SWE-01-T3", "32260003", "SWE-01"), ("SWE-01-T3", "32260004", "SWE-01"),
            ("SWE-01-T1", "32260007", "SWE-01"), ("SWE-01-T1", "32260008", "SWE-01"),
            ("CAP-01-T1", "32260001", "CAP-01"), ("CAP-01-T1", "32260005", "CAP-01"),
            ("CAP-01-T1", "32260006", "CAP-01"),
            ("AI-01-T1", "32260002", "AI-01"), ("AI-01-T1", "32260007", "AI-01"),
            ("AI-01-T2", "32260003", "AI-01"), ("AI-01-T2", "32260008", "AI-01"),
        ]
        
        for p in SEED_TEAM_MEMBERS:
            cursor.execute("""
                INSERT INTO team_members (team_id, login_id, course_id)
                VALUES (?, ?, ?)
            """, p)  
 


    conn.commit()
    conn.close()


def verify_api_key(x_api_key : Optional[str] = Header(None)):
    if not x_api_key or not secrets.compare_digest(x_api_key, PORTAL_API_KEY):
        raise HTTPException(status_code=401, detail="포털 API 키가 없거나 틀렸습니다")

@app.get("/portal/people/{login_id}")
def get_portal_person(login_id: str, _: None = Depends(verify_api_key)):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT login_id, name, role, department FROM people WHERE login_id = ?", (login_id,))
    row = cursor.fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="해당하는 id의 유저를 찾을 수 없습니다.")
    return {"login_id": row[0], "name": row[1], "role": row[2], "department": row[3]}

@app.get("/portal/students/{login_id}/courses")
def get_student_info(login_id: str, _: None = Depends(verify_api_key)):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT role FROM people WHERE login_id = ?", (login_id,))
    role = cursor.fetchone()
    if not role:
        conn.close()
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다.")
    if role[0] != "student":
        conn.close()
        raise HTTPException(status_code=404, detail="이 학생의 과목이 없습니다.")

    cursor.execute("""
        SELECT c.course_id, c.code, c.title, c.schedule, c.start_date, c.has_team_project, 
            p.login_id, p.name, p.department
        FROM enrollments e
        JOIN courses c ON c.course_id = e.course_id
        JOIN people p ON p.login_id = c.professor_id
        WHERE e.login_id = ?
    """, (login_id,))

    course_res = []
    rows = cursor.fetchall()
    for row in rows:
        cursor.execute("""
            SELECT t.team_id, t.name FROM team_members m
            JOIN teams t ON m.team_id = t.team_id
            WHERE login_id = ? AND t.course_id = ?
        """, (login_id, row[0]))
        team = cursor.fetchone()
        if team:
            cursor.execute("""
                SELECT p.login_id, p.name, p.department FROM people p
                JOIN team_members m ON m.login_id = p.login_id 
                WHERE m.team_id = ?
            """, (team[0],))
            team_members = cursor.fetchall()
        else:
            team_members = None

        course_res.append({
            "course_id": row[0],
            "code": row[1],
            "title": row[2],
            "schedule": row[3],
            "start_date": row[4],
            "has_team_project": bool(row[5]),
            "professor": {
                "login_id": row[6],
                "name": row[7],
                "department": row[8]
            },
            "team": {
                "team_id": team[0],
                "name": team[1],
                "members": [{"login_id": member[0],
                             "name": member[1],
                             "department": member[2]} for member in team_members]
            } if team else None
        })

    conn.close()
    return course_res
