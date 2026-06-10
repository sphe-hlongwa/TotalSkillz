import re
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, field_validator
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import yt_dlp
import logging
import os
import sentry_sdk

sentry_sdk.init(
    dsn="https://fa1dada52bba2b735b61264aeafc7b6c@o4511536084484096.ingest.us.sentry.io/4511536224075776",
    traces_sample_rate=1.0,
    profiles_sample_rate=1.0,
    send_default_pii=True,
)
# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ---- Rate Limiter Setup ----
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(title="TotalSkillz Video Backend")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# ---- CORS (tightened from "*") ----
ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "https://totalskillz.web.app",
    "https://totalskillz-7193a.web.app",
    "https://totalskillz.firebaseapp.com",
    "https://totalskillz-7193a.firebaseapp.com",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Authorization"],
)

# ---- YouTube URL Validation ----
YOUTUBE_URL_REGEX = re.compile(
    r'^https?://(www\.)?(youtube\.com|youtu\.be|m\.youtube\.com)/.+'
)

class VideoRequest(BaseModel):
    url: str = Field(..., max_length=2048, description="YouTube video URL")

    @field_validator('url')
    @classmethod
    def validate_youtube_url(cls, v: str) -> str:
        v = v.strip()
        if not YOUTUBE_URL_REGEX.match(v):
            raise ValueError('URL must be a valid YouTube link (youtube.com or youtu.be)')
        return v

@app.get("/")
async def root():
    return {"message": "TotalSkillz Video API is active"}

@app.post("/api/video/info")
@limiter.limit("10/minute")
async def get_video_info(request: Request, video_req: VideoRequest):
    ydl_opts = {
        'quiet': True,
        'no_warnings': True,
        'format': 'best',
        'skip_download': True,
    }
    
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_req.url, download=False)
            
            # Extract relevant fields for our frontend
            description = info.get("description") or ""
            data = {
                "id": info.get("id"),
                "title": info.get("title"),
                "thumbnail": info.get("thumbnail"),
                "duration": info.get("duration"),
                "view_count": info.get("view_count"),
                "uploader": info.get("uploader"),
                "description": description[:500] + "..." if len(description) > 500 else description
            }
            return data
    except Exception as e:
        logger.error(f"Error extracting video info: {e}")
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

