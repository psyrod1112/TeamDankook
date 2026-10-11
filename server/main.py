from fastapi import FastAPI
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="TeamDankook API", version="1.0.0")

SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError("SECRET_KEY가 .env에 없습니다")

@app.get("/api/health")
def health_check():
    return {"status": "ok!"}