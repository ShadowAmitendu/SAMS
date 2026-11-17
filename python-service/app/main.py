from fastapi import FastAPI

app = FastAPI(title="SAMS Processing Service")


@app.get("/health")
def health():
    return {"status": "UP", "service": "SAMS Processing Service"}
