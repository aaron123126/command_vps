from flask import Flask, request, jsonify
import os
import json
from functools import wraps

app = Flask(__name__)

# Vercel uses a temporary directory for its serverless functions.
CONFIG_DIR = '/tmp/configs'
if not os.path.exists(CONFIG_DIR):
    os.makedirs(CONFIG_DIR)

AUTH_TOKEN = os.environ.get('AUTH_TOKEN')

def authenticate_token(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not AUTH_TOKEN:
            return jsonify({"error": "Server not configured with AUTH_TOKEN"}), 500
        
        token = request.headers.get('X-Auth-Token')
        if token == AUTH_TOKEN:
            return f(*args, **kwargs)
        else:
            return jsonify({"error": "Unauthorized"}), 401
    return decorated_function

@app.route('/')
def home():
    return "VPS Config Server is running."

@app.route('/api/config/<user_id>', methods=['GET'])
@authenticate_token
def get_config(user_id):
    config_path = os.path.join(CONFIG_DIR, f'{user_id}.json')
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            config = json.load(f)
        return jsonify(config)
    else:
        return jsonify({"error": "User configuration not found"}), 404

@app.route('/api/config/<user_id>', methods=['POST'])
@authenticate_token
def set_config(user_id):
    config_path = os.path.join(CONFIG_DIR, f'{user_id}.json')
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON"}), 400
    
    with open(config_path, 'w') as f:
        json.dump(data, f, indent=4)
    
    return jsonify({"message": f"Configuration for {user_id} saved successfully."})

@app.route('/api/config/create/<user_id>', methods=['POST'])
@authenticate_token
def create_config(user_id):
    config_path = os.path.join(CONFIG_DIR, f'{user_id}.json')
    if os.path.exists(config_path):
        return jsonify({"error": "User configuration already exists"}), 409

    # Create a default empty config
    default_config = {
        "packages": [],
        "files": {}
    }
    with open(config_path, 'w') as f:
        json.dump(default_config, f, indent=4)

    return jsonify({"message": f"New configuration for {user_id} created successfully."})

@app.route('/api/config/<user_id>', methods=['DELETE'])
@authenticate_token
def delete_config(user_id):
    config_path = os.path.join(CONFIG_DIR, f'{user_id}.json')
    if os.path.exists(config_path):
        os.remove(config_path)
        return jsonify({"message": f"Configuration for {user_id} deleted successfully."})
    else:
        return jsonify({"error": "User configuration not found"}), 404

if __name__ == '__main__':
    # This part is for local testing and won't be used by Vercel
    app.run(debug=True)
