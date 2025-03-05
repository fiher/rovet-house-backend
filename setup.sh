#!/bin/bash

set -e  # Exit immediately if any command fails

# Define dependencies
deps=("docker" "docker-compose" "python3" "pip3" "git")

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL 
https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Function to check and install dependencies
install_dependency() {
    if ! command -v "$1" &>/dev/null; then
        echo "$1 is not installed. Installing..."
        brew install "$1"
    else
        echo "$1 is already installed."
    fi
}

# Install missing dependencies
for dep in "${deps[@]}"; do
    install_dependency "$dep"
done

echo "Setting up project structure..."
mkdir -p app tests

echo "Creating .gitignore..."
cat <<EOF > .gitignore
__pycache__/
.env
venv/
*.pyc
dist/
EOF

echo "Creating .env file..."
cat <<EOF > .env
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=guesthouse
EOF

echo "Creating Dockerfile..."
cat <<EOF > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

echo "Creating docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8000:8000"
    depends_on:
      - db
    env_file:
      - .env
    environment:
      DATABASE_URL: 
postgresql://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@db:5432/\${POSTGRES_DB}
  db:
    image: postgres:15
    restart: always
    env_file:
      - .env
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
EOF

echo "Creating requirements.txt..."
cat <<EOF > requirements.txt
fastapi
uvicorn
SQLAlchemy
asyncpg
alembic
pytest
black
isort
flake8
EOF

echo "Creating app/main.py..."
cat <<EOF > app/main.py
from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}
EOF

echo "Creating test file..."
cat <<EOF > tests/test_main.py
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, World!"}
EOF

echo "Creating README.md..."
cat <<EOF > README.md
# Python REST API with FastAPI and PostgreSQL

## Requirements
- macOS with Homebrew installed
- Docker
- Docker Compose
- Python 3.x

## Setup
Run the following command to build and start the service:

\`\`\`sh
docker-compose up --build
\`\`\`

The API will be available at: 
[http://localhost:8000](http://localhost:8000)

## Running Tests
To run tests, use:

\`\`\`sh
docker-compose exec web pytest
\`\`\`

## Linting
To lint the code, run:

\`\`\`sh
docker-compose exec web black .
docker-compose exec web isort .
docker-compose exec web flake8
\`\`\`
EOF

echo "✅ Setup complete! Run 'docker-compose up --build' to start the 
service."

