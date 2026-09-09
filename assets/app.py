from flask import Flask
import os

app = Flask(__name__)

VERSION = "v1"
BROKEN = False


@app.get("/")
def index():
    slot = os.getenv("SLOT", "unknown")
    return f"""
    <h1>Continuous Deployment Demo</h1>
    <p>Version: {VERSION}</p>
    <p>Slot: {slot}</p>
    """


@app.get("/health")
def health():
    if BROKEN:
        return "unhealthy", 500

    return "ok", 200
