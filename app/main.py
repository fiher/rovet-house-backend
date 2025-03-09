from fastapi import FastAPI
import os

app = FastAPI() # Make a change for the sake of it
# Example
@app.get("/")
def read_root():
    return {"message": "Hello, World!"}
