import os

import uvicorn
from fastapi import FastAPI
from fastapi.responses import JSONResponse, PlainTextResponse

app = FastAPI()


def environment() -> str:
    return os.getenv("ENVIRONMENT", "unknown")


def force_unhealthy() -> bool:
    return os.getenv("FORCE_UNHEALTHY", "").lower() in ("1", "true", "yes")


@app.get("/", response_class=PlainTextResponse)
def root() -> str:
    return f"Hello World from {environment()}"


@app.get("/health")
def health() -> JSONResponse:
    if force_unhealthy():
        return JSONResponse(
            status_code=500,
            content={"status": "unhealthy", "environment": environment()},
        )
    return JSONResponse(content={"status": "ok", "environment": environment()})


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
