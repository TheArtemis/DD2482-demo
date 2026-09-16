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
    <!doctype html>
    <html lang="en">
    <head>
        <title>Continuous Deployment Demo</title>
        <style>
            body {{
                background: #eaf4ff;
                color: #17324d;
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 60px 20px;
            }}
            .version {{
                background: #cfe5ff;
                border-radius: 8px;
                display: inline-block;
                padding: 12px 24px;
            }}
            a {{ color: #1766a6; }}
        </style>
    </head>
    <body>
        <h1>Continuous Deployment Demo</h1>
        <p class="version">Version: {VERSION}</p>
        <p>Slot: {slot}</p>
        <p><a href="/logs">Live deployment logs</a></p>
    </body>
    </html>
    """


@app.get("/health")
def health():
    if BROKEN:
        return "unhealthy", 500

    return "ok", 200
