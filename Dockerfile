FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    libgl1 \
    libglib2.0-0 \
    libx11-6 \
    libsm6 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

ENV PORT=5000
EXPOSE 5000


CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
