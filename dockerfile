FROM python:3.13-slim

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app/

# Install dependencies for building NumPy
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    python3-dev \
    build-essential \
    libatlas-base-dev \
    && rm -rf /var/lib/apt/lists/*

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8000 from the container
EXPOSE 8000

# Run FastAPI.py when the container launches
CMD ["python", "Fastapi.py"]

