# Use the latest stable Python image
FROM python:3.12-slim

# Set working directory in the container
WORKDIR /app

# Copy the shared requirements file from root
COPY ../../requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the user_service code
COPY . .

# Expose FastAPI's default port
EXPOSE 8000

# Run FastAPI app using Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
