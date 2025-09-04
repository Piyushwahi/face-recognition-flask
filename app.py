import os
import json
import face_recognition
from flask import Flask, render_template, request, redirect, url_for
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Save uploads inside static/uploads
UPLOAD_FOLDER = os.path.join("static", "uploads")
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

# ------------------- Load Users -------------------
def load_users():
    with open("database.json", "r") as f:
        return json.load(f)

# ------------------- Load Encodings -------------------
def load_known_faces():
    users = load_users()
    known_encodings = []
    known_names = []

    for user in users:
        folder = os.path.join("uploads", user["folder"])  # training images (not static)
        if not os.path.exists(folder):
            continue

        for filename in os.listdir(folder):
            filepath = os.path.join(folder, filename)
            try:
                img = face_recognition.load_image_file(filepath)
                encs = face_recognition.face_encodings(img)
                if encs:
                    known_encodings.append(encs[0])
                    known_names.append(user["folder"])
            except Exception as e:
                print(f"Error processing {filepath}: {e}")

    return known_encodings, known_names


known_face_encodings, known_face_names = load_known_faces()

# ------------------- Routes -------------------
@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        if "file" not in request.files:
            return redirect(request.url)

        file = request.files["file"]
        if file.filename == "":
            return redirect(request.url)

        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)
        file.save(filepath)

        # Load uploaded image
        img = face_recognition.load_image_file(filepath)
        encs = face_recognition.face_encodings(img)

        if not encs:
            return render_template("index.html", error="No face detected!")

        uploaded_encoding = encs[0]

        # Compare with known faces
        results = face_recognition.compare_faces(known_face_encodings, uploaded_encoding)
        if True in results:
            match_index = results.index(True)
            person_name = known_face_names[match_index]

            # fetch info from database.json
            users = load_users()
            info = next((u for u in users if u["folder"] == person_name), {})

            return render_template(
                "index.html",
                name=info.get("name", "Unknown"),
                age=info.get("age", ""),
                college=info.get("college", ""),
                skills=info.get("skills", []),
                github=info.get("github", ""),
                linkedin=info.get("linkedin", ""),
                uploaded_image=url_for("static", filename=f"uploads/{filename}"),
                detected=True,
            )

        return render_template("index.html", error="No match found!")

    return render_template("index.html")


if __name__ == "__main__":
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)  # auto create uploads folder
    app.run(debug=True)
