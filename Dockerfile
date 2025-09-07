<<<<<<< HEAD

# Use Python 3.11 (dlib is not compatible with 3.13+)
FROM python:3.11-slim

# Install system dependencies for dlib and face_recognition
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
=======
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cmake \
>>>>>>> 63ced454a7c745b3e0dc1ccc22072876f3e86d7d
    libgl1 \
    libglib2.0-0 \
    libx11-6 \
    libsm6 \
    libxext6 \
<<<<<<< HEAD
    && python -m venv /opt/venv \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip --no-cache-dir \
    && pip install --no-cache-dir -r requirements.txt
=======
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
>>>>>>> 63ced454a7c745b3e0dc1ccc22072876f3e86d7d

COPY . .

ENV PORT=5000
EXPOSE 5000

<<<<<<< HEAD
# Use the PORT env variable for Railway compatibility
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]
=======

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
>>>>>>> 63ced454a7c745b3e0dc1ccc22072876f3e86d7d
