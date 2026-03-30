# Face Recognition Flask

## Project Overview
Face Recognition Flask is a web application built using Flask and integrated with face recognition capabilities. The application allows users to upload images and recognize faces using modern machine learning techniques.

## Features
- Detect and recognize faces in images.
- User-friendly web interface.
- Real-time face recognition.
- Easy installation and configuration.
- Built-in support for multiple image formats.

## Installation
To install and set up the project locally, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/Piyushwahi/face-recognition-flask.git
   cd face-recognition-flask
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   ```

3. Activate the virtual environment:
   - On Windows:
     ```bash
     venv\Scripts\activate
     ```
   - On macOS and Linux:
     ```bash
     source venv/bin/activate
     ```

4. Install the required packages:
   ```bash
   pip install -r requirements.txt
   ```

## Usage
To run the application locally, execute the following command:
```bash
python app.py
```
Navigate to `http://127.0.0.1:5000` in your browser to access the application.

## Project Structure
```
face-recognition-flask/
├── app.py                # Main application file
├── templates/            # Contains HTML templates
│   ├── index.html
│   └── result.html
├── static/               # Contains static files like CSS, JS, and images
├── requirements.txt      # Python packages required
└── README.md             # Project documentation
```

## Deployment Instructions
For deploying the application in a production environment, consider using services like Heroku, AWS, or DigitalOcean. The following steps outline a basic deployment using Heroku:

1. Create a Heroku account and install the Heroku CLI.
2. Navigate to your project directory.
3. Log in to Heroku:
   ```bash
   heroku login
   ```
4. Create a new Heroku application:
   ```bash
   heroku create your-app-name
   ```
5. Push your code to Heroku:
   ```bash
   git push heroku main
   ```
6. Open your application:
   ```bash
   heroku open
   ```

For more advanced configurations, consider using a `Procfile` and specifying environment variables.
