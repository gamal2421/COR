import sys
import json
import logging
import google.generativeai as ai
from PyPDF2 import PdfReader
from docx import Document

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configure the API key for Google Generative AI
ai.configure(api_key="AIzaSyC8lJJUicaOFeHBg1xrtLnn26cRhPlPb5s")

# Function to extract text from various file types
def extract_text_from_file(file_path):
    """Extracts text from PDF, DOCX, or TXT."""
    if file_path.endswith('.pdf'):
        return extract_text_from_pdf(file_path)
    elif file_path.endswith('.docx'):
        return extract_text_from_docx(file_path)
    elif file_path.endswith('.txt'):
        return extract_text_from_txt(file_path)
    else:
        return ""

def extract_text_from_pdf(file_path):
    try:
        reader = PdfReader(file_path)
        return "".join([page.extract_text() or "" for page in reader.pages])
    except Exception as e:
        logger.error(f"Error reading PDF: {e}")
        return ""

def extract_text_from_docx(file_path):
    try:
        doc = Document(file_path)
        return "\n".join([p.text for p in doc.paragraphs])
    except Exception as e:
        logger.error(f"Error reading DOCX: {e}")
        return ""

def extract_text_from_txt(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return file.read()
    except Exception as e:
        logger.error(f"Error reading TXT: {e}")
        return ""

# Function to extract structured information from CV text using Generative AI
def extract_info(cv_text):
    """Extracts structured information from CV text."""
    prompt = f"""
    Extract the following information from the CV:
    - Full Name
    - Email address
    - Phone number
    - LinkedIn
    - GitHub
    - Education
    - Certifications
    - Skills
    - Projects
    -- if there any more info make a header for it and add it
    -- if no Certifications  = dont have any Certifications
    -- make the null =  not provided
    - Return the result in JSON format.

    CV text:
    {cv_text}
    """
    model = ai.GenerativeModel("gemini-pro")
    chat = model.start_chat()
    response = chat.send_message(prompt)

    try:
        extracted_info = json.loads(response.text.strip().lstrip('```json').rstrip('```').strip())
        return extracted_info  # Return the parsed JSON directly
    except json.JSONDecodeError:
        logger.error("Failed to parse JSON")
        return {}

if __name__ == "__main__":
    # Ensure file path is passed as an argument
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No file provided"}))
        sys.exit(1)

    file_path = sys.argv[1]  # Input file path

    # Extract text from the provided file
    text = extract_text_from_file(file_path)

    if not text:
        print(json.dumps({"error": "Failed to extract text"}))
        sys.exit(1)

    # Extract structured information from the CV text
    result = extract_info(text)

    # Output the JSON result directly
    print(json.dumps(result))