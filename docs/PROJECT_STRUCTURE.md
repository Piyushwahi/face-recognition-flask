# Project Structure

## Directory Layout

```
face-recognition-flask/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions CI/CD pipeline
├── docs/
│   ├── PROJECT_STRUCTURE.md   # This file
│   └── DEPLOYMENT.md          # Deployment guide
├── src/
│   └── app.py                 # Application entry-point (alternative)
├── static/
│   └── uploads/               # Uploaded images served statically
├── templates/
│   └── index.html             # Jinja2 HTML template
├── uploads/                   # Training images (one sub-folder per person)
│   └── <person_folder>/
│       ├── photo1.jpg
│       └── photo2.jpg
├── .dockerignore              # Files excluded from the Docker build context
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules
├── app.py                     # Main Flask application
├── appa.py                    # Alternate/experimental entry-point
├── database.json              # User data (name, age, college, skills, links)
├── docker-compose.yml         # Local development Docker Compose config
├── Dockerfile                 # Production Docker image definition
├── fix_images.py              # Utility: pre-process training images
├── Procfile                   # Process definition for Railway / Heroku
├── railway.toml               # Railway deployment configuration
├── README.md                  # Project overview and quick-start guide
└── requirements.txt           # Python dependencies (pinned versions)
```

---

## Key Files Explained

| File | Purpose |
|---|---|
| `app.py` | Flask application – routes, face encoding, recognition logic |
| `database.json` | JSON store of registered users and their metadata |
| `Dockerfile` | Multi-stage Docker image built on `python:3.11-slim` |
| `docker-compose.yml` | Brings up the web service locally with a single command |
| `requirements.txt` | Pinned Python dependencies for reproducible installs |
| `Procfile` | Tells Railway/Heroku how to start the web process |
| `railway.toml` | Railway-specific build configuration (system packages) |
| `.env.example` | Template for environment variables – copy to `.env` |

---

## Local Development Setup

### Prerequisites

- Python 3.8 – 3.11 (the Docker image uses 3.11; the CI matrix tests 3.8, 3.9 and 3.10)
- `cmake` and build tools (required by `dlib`)
- Docker & Docker Compose (optional but recommended)

### Option A – Plain Python

```bash
# 1. Clone the repo
git clone https://github.com/Piyushwahi/face-recognition-flask.git
cd face-recognition-flask

# 2. Create and activate a virtual environment
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# 3. Install system dependencies (Ubuntu / Debian)
sudo apt-get install -y build-essential cmake libgl1 libglib2.0-0

# 4. Install Python dependencies
pip install -r requirements.txt

# 5. Copy and configure environment variables
cp .env.example .env
# Edit .env and set SECRET_KEY and any other values

# 6. Run the development server
python app.py
# Visit http://127.0.0.1:5000
```

### Option B – Docker Compose (recommended)

```bash
# Build and start the service
docker compose up --build

# Visit http://localhost:5000

# Stop the service
docker compose down
```

---

## Adding a New Person to the Database

1. Create a folder under `uploads/` named after the person (no spaces, e.g. `john_doe`).
2. Add at least 2–3 clear face photos to that folder.
3. Add a corresponding entry to `database.json`:

```json
{
  "folder": "john_doe",
  "name": "John Doe",
  "age": "25",
  "college": "MIT",
  "skills": ["Python", "ML"],
  "github": "https://github.com/johndoe",
  "linkedin": "https://linkedin.com/in/johndoe"
}
```

4. Restart the application so the new encodings are loaded.

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `FLASK_ENV` | `production` | Flask run mode (`development` / `production`) |
| `DEBUG` | `False` | Enable Flask debug mode |
| `SECRET_KEY` | *(required)* | Secret key for Flask sessions |
| `UPLOAD_FOLDER` | `static/uploads` | Directory for uploaded images |
| `PORT` | `5000` | Port the server listens on |

---

## Docker Setup

### Build the image manually

```bash
docker build -t face-recognition-flask .
docker run -p 5000:5000 face-recognition-flask
```

### Using Docker Compose

```bash
docker compose up --build      # first run
docker compose up -d           # detached (background)
docker compose logs -f         # stream logs
docker compose down            # stop and remove containers
```

---

## CI/CD Pipeline

The `.github/workflows/ci-cd.yml` pipeline runs on every push / PR to `main`:

1. **Lint** – `flake8` checks for syntax errors and style issues across Python 3.8, 3.9 and 3.10.
2. **Test** – `pytest` with coverage reporting.
3. **Docker build** – verifies the image builds successfully.
4. **Deploy** – triggers a Railway deployment on merges to `main` (requires `RAILWAY_TOKEN` secret).

See [DEPLOYMENT.md](DEPLOYMENT.md) for full deployment instructions.
