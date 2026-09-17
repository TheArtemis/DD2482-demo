from flask import Flask
import os

app = Flask(__name__)

VERSION = "v3"
BROKEN = True



@app.get("/")
def index():
    if BROKEN:
        return "application error", 500

    slot = os.getenv("SLOT", "unknown").upper()
    slot_class = slot.lower() if slot in {"BLUE", "GREEN"} else "unknown"
    return f"""
    <!doctype html>
    <html lang="en">
    <head>
        <title>Continuous Deployment Demo</title>
        <style>
            body {{
                box-sizing: border-box;
                min-height: 100vh;
                margin: 0;
                background: #334155;
                color: #fff;
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 12vh 20px 40px;
            }}
            body.slot-blue {{
                background: linear-gradient(135deg, #0735a3, #0878e8);
            }}
            body.slot-green {{
                background: linear-gradient(135deg, #075c2a, #09aa54);
            }}
            h1 {{ font-size: clamp(2.5rem, 6vw, 5rem); margin: 0 0 36px; }}
            .slot {{
                display: inline-block;
                border: 5px solid #fff;
                border-radius: 16px;
                padding: 18px 40px;
                font-size: clamp(3rem, 9vw, 7rem);
                font-weight: 900;
                letter-spacing: .08em;
                text-shadow: 0 3px 8px #0007;
            }}
            .version {{
                background: #fff;
                color: #172033;
                border-radius: 12px;
                display: inline-block;
                padding: 14px 32px;
                font-size: 2rem;
                font-weight: bold;
            }}
            a {{ color: #fff; font-size: 1.3rem; }}
        </style>
    </head>
    <body class="slot-{slot_class}">
        <h1>Continuous Deployment Demo</h1>
        <p class="slot">{slot}</p>
        <p><span class="version">Version: {VERSION}</span></p>
        <p><a href="/logs">Live deployment logs</a></p>
    </body>
    </html>
    """


@app.get("/health")
def health():
    if BROKEN:
        return "unhealthy", 500

    return "ok", 200
