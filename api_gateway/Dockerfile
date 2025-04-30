FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# When building from the parent directory, use direct path (not ../requirements.txt)
COPY requirements.txt /app/requirements.txt

# Copy only the api_gateway directory contents
COPY api_gateway/ /app/

RUN pip install --no-cache-dir -r /app/requirements.txt

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]