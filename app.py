from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route('/')
def container_info():
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    
    # Get all environment variables
    env_vars = '<br>'.join([f'{key}: {value}' for key, value in os.environ.items()])

    return f"""
    <h1>Container Information</h1>
    <p><b>Hostname:</b> {hostname}</p>
    <p><b>IP Address:</b> {ip_address}</p>
    <h2>Environment Variables:</h2>
    <pre>{env_vars}</pre>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
