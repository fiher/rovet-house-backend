# Python REST API with FastAPI and PostgreSQL

## Requirements
- macOS with Homebrew installed
- Docker
- Docker Compose
- Python 3.x

## Setup
Run the following command to build and start the service:

```sh
docker-compose up --build
```

The API will be available at: 
[http://localhost:8000](http://localhost:8000)

## Running Tests
To run tests, use:

```sh
docker-compose exec web pytest
```

## Linting
To lint the code, run:

```sh
docker-compose exec web black .
docker-compose exec web isort .
docker-compose exec web flake8
```
