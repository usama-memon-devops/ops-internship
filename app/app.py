from flask import Flask, jsonify, request
import socket
from datetime import datetime
from pathlib import Path

app = Flask(__name__)
DATA_DIR = Path("/opt/myapp/data")
DATA_DIR.mkdir(parents=True, exist_ok=True)
NOTES_FILE = DATA_DIR / "notes.txt"

@app.route("/")
def home():
    hostname = socket.gethostname()
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"<h1>Project 3 - Website is running</h1><p>Hostname: {hostname}</p><p>Current time: {current_time}</p>"

@app.route("/healthz")
def healthz():
    return jsonify(status="ok")

@app.route("/notes", methods=["POST"])
def notes():
    data = request.get_json(silent=True) or {}
    note = data.get("note", "").strip()
    if not note:
        return jsonify(error="note is required"), 400
    with NOTES_FILE.open("a") as file:
        file.write(note + "\n")
    return jsonify(saved=note), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
