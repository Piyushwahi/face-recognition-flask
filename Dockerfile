
# Use Python 3.11 (dlib is not compatible with 3.13+)
FROM python:3.11-slim

# Install system dependencies for dlib and face_recognition
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libgl1 \
    libglib2.0-0 \
    libx11-6 \
    libsm6 \
    libxext6 \
    && python -m venv /opt/venv \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip --no-cache-dir \
    && pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=5000
EXPOSE 5000

# Use the PORT env variable for Railway compatibility
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]
