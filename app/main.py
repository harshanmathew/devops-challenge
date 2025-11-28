from flask import Flask, jsonify
import sys

app = Flask(__name__)

@app.route('/')
def root():
    return jsonify({"message": "Hello, Candidate", "version": "1.0.0"})

if __name__ == '__main__':
    # Ensure we bind to 0.0.0.0:80
    try:
        app.run(host='0.0.0.0', port=80)
    except PermissionError:
        print("Error: Permission denied binding to port 80. Capabilities missing.")
        sys.exit(1)
