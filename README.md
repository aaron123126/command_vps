# VPS Config Manager

This project provides a solution for managing VPS configurations through a web server deployed on Vercel and custom SSH commands within a Docker container.

## Features

*   **Web Server (Flask):** A Python Flask application that acts as a central repository for user configurations.
*   **Config Management via SSH:** Custom commands (`config pull`, `config push`, `config create`, `config del`, `config reset`) accessible via SSH to interact with the config server.
*   **Dockerized Environment:** The VPS environment is containerized using Docker, providing a consistent and isolated setup.
*   **Vercel Deployment:** The Flask web server is designed for easy deployment on Vercel.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

*   [Docker](https://docs.docker.com/get-docker/)
*   [Node.js and npm](https://nodejs.org/en/download/) (for Vercel CLI)
*   [Vercel CLI](https://vercel.com/download) (`npm install -g vercel`)

### Local Setup

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd vps
    ```

2.  **Configure Environment Variables:**

    *   **`.env` (for local development - optional):** You can create a `.env` file in the project root for local environment variables, though `start.sh` directly sets `AUTH_TOKEN`.

    *   **`vercel.env` (for Vercel deployment):**
        Create a file named `vercel.env` in the project root with the following content. **Remember to replace `your-vercel-domain.vercel.app` with your actual Vercel domain after deployment, and `your_secret_password_here` with a strong, unique password.**

        ```
        VERCEL_SERVER_DOMAIN=your-vercel-domain.vercel.app
        AUTH_TOKEN=your_secret_password_here
        ```

3.  **Set SSH Password in `start.sh`:**
    Open `start.sh` and set a strong password for the `AUTH_TOKEN` variable. This token is used for authenticating requests to your Flask server.

    ```bash
    # ...
    AUTH_TOKEN="your_secret_password_here" # CHANGE THIS!
    # ...
    ```

4.  **Build and Run the Docker Container:**
    Execute the `start.sh` script to build the Docker image and run the container.

    ```bash
    ./start.sh
    ```
    This will:
    *   Build the Docker image named `my-vps`.
    *   Run a container named `my-vps-container`.
    *   Map host port `2222` to container port `22` (for SSH).
    *   Map host port `8080` to container port `8080` (for the web app).

    You should see output similar to:
    ```
    VPS container started.
    To SSH into the container, use: ssh admin@localhost -p 2222
    The password is 'password'.
    To access the web app, open your browser to http://localhost:8080
    ```

## Usage

### Web Server

Once the Docker container is running locally, or after deploying to Vercel, you can access the web server:

*   **Local:** `http://localhost:8080`
*   **Vercel:** `https://your-vercel-domain.vercel.app`

You should see the message "VPS Config Server is running."

### SSH Custom Commands

Connect to your local VPS container via SSH:

```bash
ssh admin@localhost -p 2222
# Password: password (or whatever you set in Dockerfile/start.sh)
```

Once connected, you will be in a custom shell where you can use the following `config` commands:

*   **`config create <USER_ID>`**
    Creates a new, empty configuration for the specified `USER_ID` on the server.
    Example: `config create user123`

*   **`config pull <USER_ID>`**
    Pulls the existing configuration for `USER_ID` from the server. The configuration is saved locally to `/tmp/config_<USER_ID>.json` and its content is printed to the console.
    Example: `config pull user123`

*   **`config push <USER_ID> <PATH_TO_CONFIG_FILE>`**
    Pushes and overwrites the configuration for `USER_ID` on the server with the content of the specified local JSON file.
    Example: `config push user123 /tmp/my_new_config.json`

*   **`config del <USER_ID>`**
    Deletes the configuration for `USER_ID` from the server.
    Example: `config del user123`

*   **`config reset <USER_ID>`**
    Deletes the locally pulled configuration file (`/tmp/config_<USER_ID>.json`) for the specified `USER_ID`. This does *not* affect the server-side configuration.
    Example: `config reset user123`

*   **`exit`**
    Exits the custom SSH shell.

## Deployment to Vercel

To deploy the Flask web server to Vercel:

1.  Ensure you have the `vercel.json` and `vercel.env` files correctly configured.
2.  Run the Vercel deploy command from your project root:
    ```bash
    vercel deploy --yes
    ```
    Follow any prompts from the Vercel CLI. Once deployed, Vercel will provide you with a public URL for your web server.

## Important Notes

*   **Security:** The `AUTH_TOKEN` is crucial for securing your API. **Never hardcode sensitive tokens in your code or commit them directly to version control.** Use environment variables as implemented.
*   **Configuration Persistence:** The Flask server currently stores configurations in `/tmp/configs` within the Vercel serverless function environment. This means configurations are **not persistent** across invocations or deployments. For a production environment, you would need to integrate a persistent database (e.g., PostgreSQL, MongoDB, S3 bucket) for storing configurations.
*   **Local vs. Deployed Server:** The SSH commands within the Docker container are configured to interact with `http://localhost:8080` (the Flask server running *inside* the same Docker container). If you want your SSH commands to interact with the *deployed Vercel server*, you would need to modify `scripts/vps_cli.sh` to use the `VERCEL_SERVER_DOMAIN` environment variable instead of `http://localhost:8080`.
