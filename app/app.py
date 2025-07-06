from flask import Flask, render_template
import socket
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    hostname = socket.gethostname()
    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return render_template('index.html', hostname=hostname, now=now)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
