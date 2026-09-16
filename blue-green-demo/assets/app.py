from flask import Flask
import os

app = Flask(__name__)

VERSION = "v1"
BROKEN = False


@app.get("/")
def index():
    if BROKEN:
        return "application error", 500

    slot = os.getenv("SLOT", "unknown")
    return f"""
    <h1>Continuous Deployment Demo</h1>
    <p>Version: {VERSION}</p>
    <p>Slot: {slot}</p>
    <p><a href="/logs">Live deployment logs</a></p>
    """


@app.get("/health")
def health():
    if BROKEN:
        return "unhealthy", 500

    return "ok", 200
