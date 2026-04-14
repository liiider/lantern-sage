import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import ask, day, feedback, history, user

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(name)s %(levelname)s %(message)s")

app = FastAPI(title="Lantern Sage", version="0.1.0", description="Chinese almanac lifestyle guidance API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(day.router)
app.include_router(ask.router)
app.include_router(feedback.router)
app.include_router(history.router)
app.include_router(user.router)


@app.get("/health")
async def health():
    return {"status": "ok"}
