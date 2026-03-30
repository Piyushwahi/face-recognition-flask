# Deployment Guide

This document covers all supported deployment options for the Face Recognition Flask application.

---

## Table of Contents

1. [Environment Variables](#environment-variables)
2. [Railway.app (recommended)](#railwayapp-recommended)
3. [Heroku](#heroku)
4. [Docker + DigitalOcean](#docker--digitalocean)
5. [AWS ECS](#aws-ecs)
6. [Database Setup (PostgreSQL)](#database-setup-postgresql)
7. [Monitoring](#monitoring)
8. [Troubleshooting](#troubleshooting)
9. [Production Checklist](#production-checklist)

---

## Environment Variables

Create a `.env` file from the provided template before deploying:

```bash
cp .env.example .env
```

| Variable | Required | Description |
|---|---|---|
| `SECRET_KEY` | ✅ | A long random string – never commit this value |
| `FLASK_ENV` | ✅ | Set to `production` in all live environments |
| `DEBUG` | ✅ | Set to `False` in production |
| `UPLOAD_FOLDER` | ✅ | Path for uploaded images (`static/uploads`) |
| `PORT` | ✅ | Port the gunicorn server listens on (default `5000`) |
| `DATABASE_URL` | Optional | PostgreSQL connection string (future use) |

Generate a strong secret key:

```python
python -c "import secrets; print(secrets.token_hex(32))"
```

---

## Railway.app (recommended)

Railway.app provides the easiest zero-configuration deployment. The repository already includes `railway.toml` which declares the required system packages.

### Steps

1. Sign in at <https://railway.app> and click **New Project → Deploy from GitHub repo**.
2. Select `Piyushwahi/face-recognition-flask`.
3. Railway auto-detects the `Dockerfile` and begins building.
4. In the **Variables** tab add:
   - `SECRET_KEY` → your generated secret
   - `FLASK_ENV` → `production`
   - `DEBUG` → `False`
5. Click **Deploy** – Railway assigns a public URL automatically.

### Custom Domain

In the Railway project settings navigate to **Domains** and add your custom domain. Update your DNS provider with the CNAME record Railway provides.

---

## Heroku

### Prerequisites

- Heroku CLI installed (`brew install heroku/brew/heroku` or equivalent)
- A free/paid Heroku account

### Steps

```bash
# 1. Login
heroku login

# 2. Create a new app
heroku create your-app-name

# 3. Set environment variables
heroku config:set SECRET_KEY="$(python -c 'import secrets; print(secrets.token_hex(32))')"
heroku config:set FLASK_ENV=production
heroku config:set DEBUG=False

# 4. Deploy
git push heroku main

# 5. Open the app
heroku open
```

### Container Registry (Docker)

```bash
heroku container:login
heroku container:push web -a your-app-name
heroku container:release web -a your-app-name
```

> **Note:** Heroku's free tier has been discontinued. Use the Eco or Basic dynos for low-cost hosting.

---

## Docker + DigitalOcean

### 1. Create a Droplet

Log in to the [DigitalOcean Control Panel](https://cloud.digitalocean.com) and create a Ubuntu 22.04 Droplet (minimum 2 GB RAM recommended for `dlib` / `face_recognition`).

### 2. Install Docker on the Droplet

```bash
ssh root@<droplet-ip>

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker
```

### 3. Deploy the Application

```bash
# Clone the repository on the Droplet
git clone https://github.com/Piyushwahi/face-recognition-flask.git
cd face-recognition-flask

# Copy environment file
cp .env.example .env
# Edit .env and set production values
nano .env

# Build and start
docker compose up -d --build
```

### 4. Configure a Reverse Proxy (nginx)

```bash
apt-get install -y nginx

cat > /etc/nginx/sites-available/face-recognition << 'EOF'
server {
    listen 80;
    server_name your-domain.com;

    client_max_body_size 16M;

    location / {
        proxy_pass         http://127.0.0.1:5000;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
EOF

ln -s /etc/nginx/sites-available/face-recognition /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

### 5. Enable HTTPS with Certbot

```bash
apt-get install -y certbot python3-certbot-nginx
certbot --nginx -d your-domain.com
```

---

## AWS ECS

### Prerequisites

- AWS CLI configured (`aws configure`)
- An ECR repository created

### Steps

```bash
# 1. Authenticate with ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    <account-id>.dkr.ecr.us-east-1.amazonaws.com

# 2. Build and tag the image
docker build -t face-recognition-flask .
docker tag face-recognition-flask:latest \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/face-recognition-flask:latest

# 3. Push to ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/face-recognition-flask:latest

# 4. Create ECS Cluster, Task Definition, and Service via AWS Console
#    or Infrastructure-as-Code (CloudFormation / Terraform).
```

**Recommended instance type:** `t3.medium` (2 vCPU, 4 GB RAM) or larger due to the memory requirements of `dlib`.

---

## Database Setup (PostgreSQL)

The application currently uses `database.json` as its data store. To migrate to PostgreSQL:

### Railway Postgres add-on

1. In the Railway project click **+ New** → **Database** → **PostgreSQL**.
2. Railway automatically injects `DATABASE_URL` into your service's environment.

### Heroku Postgres

```bash
heroku addons:create heroku-postgresql:mini -a your-app-name
# DATABASE_URL is set automatically
```

### DigitalOcean Managed Database

1. Create a Managed PostgreSQL cluster in the DigitalOcean Control Panel.
2. Copy the connection string and add it as `DATABASE_URL` in your `.env` or hosting platform.

---

## Monitoring

### Application Logs

```bash
# Railway
railway logs

# Heroku
heroku logs --tail -a your-app-name

# Docker Compose
docker compose logs -f web

# Docker standalone
docker logs -f <container-id>
```

### Health Check Endpoint

Add the following route to `app.py` for uptime monitoring:

```python
@app.route("/health")
def health():
    return {"status": "ok"}, 200
```

### Uptime Monitoring Services

- [UptimeRobot](https://uptimerobot.com) – free tier monitors every 5 minutes
- [Betterstack](https://betterstack.com) – advanced alerting and on-call
- [AWS CloudWatch](https://aws.amazon.com/cloudwatch/) – native AWS monitoring

---

## Troubleshooting

### Build fails: `cmake` not found

Ensure the system dependencies are installed. The `Dockerfile` and `railway.toml` already include them. For local builds:

```bash
sudo apt-get install -y build-essential cmake pkg-config
```

### `dlib` installation takes too long

`dlib` compiles from source and can take 10–20 minutes. Use Docker layer caching or pre-built wheels where available.

### Port already in use

Change the host port in `docker-compose.yml`:

```yaml
ports:
  - "5001:5000"   # map host port 5001 to container port 5000
```

### No face detected

- Ensure the uploaded image contains a clearly visible, front-facing face.
- Use well-lit, high-resolution images for training (stored in `uploads/<person_folder>/`).

### Recognition accuracy is low

- Add more training images per person (5+ recommended).
- The tolerance threshold in `app.py` is set to `0.45` – lower values are stricter.

---

## Production Checklist

- [ ] `SECRET_KEY` is a long random string and is **not** committed to the repository
- [ ] `FLASK_ENV` is set to `production`
- [ ] `DEBUG` is set to `False`
- [ ] HTTPS is enabled (SSL/TLS certificate)
- [ ] `database.json` / database does not contain sensitive plain-text passwords
- [ ] `uploads/` training data is backed up regularly
- [ ] A health-check endpoint (`/health`) is configured
- [ ] Uptime monitoring is active
- [ ] Docker image is rebuilt and redeployed on every merge to `main` (CI/CD pipeline)
- [ ] Log retention is configured on the hosting platform
- [ ] `MAX_CONTENT_LENGTH` limits file upload size (currently 16 MB)
