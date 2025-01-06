from flask import Flask, request, jsonify
import os
import tempfile
from werkzeug.utils import secure_filename
import logging
import json
from datetime import datetime
from PyPDF2 import PdfReader
from docx import Document
import google.generativeai as ai

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configure AI API
ai.configure(api_key='AIzaSyC8lJJUicaOFeHBg1xrtLnn26cRhPlPb5s')  # Replace with your actual API key

def ask_ai_to_extract_info(input_text):
    input_text = input_text.replace("\n", " ")
    prompt = f"""
    Analyze the following CV and extract the following information:
    - Full Name
    - Email address
    - Phone number
    - LinkedIn profile
    - GitHub profile
    - Education (degrees, institutions)
    - Certifications
    - Skills (technical skills, programming languages, tools)
    - Projects

    Format the extracted information in JSON format.
    if there is any thing null or Not provided put Not provided in it 
    CV text: 
    {input_text}
    """
    model = ai.GenerativeModel("gemini-pro")
    chat = model.start_chat()
    response = chat.send_message(prompt)
    cleaned_response = response.text.strip().lstrip('```json').rstrip('```').strip()

    try:
        parsed_json = json.loads(cleaned_response)
        return json.dumps(parsed_json, indent=4, ensure_ascii=False)
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse AI response as JSON: {e}")
        return cleaned_response

def extract_text_from_pdf(file_path):
    try:
        reader = PdfReader(file_path)
        text = ""
        for page in reader.pages:
            text += page.extract_text() or ""
        return text
    except Exception as e:
        logger.error(f"Error reading PDF {file_path}: {e}")
        return ""

def extract_text_from_docx(file_path):
    try:
        doc = Document(file_path)
        text = "\n".join([paragraph.text for paragraph in doc.paragraphs])
        return text
    except Exception as e:
        logger.error(f"Error reading DOCX {file_path}: {e}")
        return ""

def extract_text_from_txt(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return file.read()
    except Exception as e:
        logger.error(f"Error reading TXT {file_path}: {e}")
        return ""

def clean_text(text):
    return text.strip()

def extract_text_from_file(file_path):
    if file_path.endswith('.pdf'):
        return extract_text_from_pdf(file_path)
    elif file_path.endswith('.docx'):
        return extract_text_from_docx(file_path)
    elif file_path.endswith('.txt'):
        return extract_text_from_txt(file_path)
    return ""

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    temp_dir = tempfile.mkdtemp()
    filename = secure_filename(file.filename)
    file_path = os.path.join(temp_dir, filename)
    file.save(file_path)

    raw_text = extract_text_from_file(file_path)
    if not raw_text:
        return jsonify({'error': 'Failed to extract text'}), 500

    cleaned_text = clean_text(raw_text)
    extracted_info = ask_ai_to_extract_info(cleaned_text)

    try:
        extracted_info_json = json.loads(extracted_info)
        return jsonify(extracted_info_json)
    except json.JSONDecodeError:
        logger.error(f"Invalid JSON extracted from {filename}.")
        return jsonify({'error': 'Failed to parse extracted information'}), 500
    finally:
        os.remove(file_path)
        os.rmdir(temp_dir)

if __name__ == "__main__":
    app.run(debug=True, port=5000)
