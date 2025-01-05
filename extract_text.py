import os
import json
from datetime import datetime
from PyPDF2 import PdfReader
from docx import Document
import logging
import google.generativeai as ai

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

ai.configure(api_key='AIzaSyC8lJJUicaOFeHBg1xrtLnn26cRhPlPb5s') 

def ask_ai_to_extract_info(input_text):
    """Function to send the user's input to the AI model for extraction of key information."""
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

    CV text: 
    {input_text}
    """
    model = ai.GenerativeModel("gemini-pro")
    chat = model.start_chat()
    response = chat.send_message(prompt)

    # Extract and clean the response from the AI model
    cleaned_response = response.text.strip().lstrip('```json').rstrip('```').strip()

    try:
        # Parse and reformat the JSON to ensure proper formatting
        parsed_json = json.loads(cleaned_response)
        return json.dumps(parsed_json, indent=4, ensure_ascii=False)  # Return clean JSON
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse AI response as JSON: {e}")
        return cleaned_response  # Fallback to raw cleaned response

def extract_text_from_pdf(file_path):
    """Extracts text from a PDF file."""
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
    """Extracts text from a DOCX file."""
    try:
        doc = Document(file_path)
        text = "\n".join([paragraph.text for paragraph in doc.paragraphs])
        return text
    except Exception as e:
        logger.error(f"Error reading DOCX {file_path}: {e}")
        return ""

def extract_text_from_txt(file_path):
    """Extracts text from a TXT file."""
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return file.read()
    except Exception as e:
        logger.error(f"Error reading TXT {file_path}: {e}")
        return ""

def clean_text(text):
    """Clean and normalize text."""
    return text.strip()

def extract_text_from_file(file_path):
    """Extract text based on file extension."""
    if file_path.endswith('.pdf'):
        return extract_text_from_pdf(file_path)
    elif file_path.endswith('.docx'):
        return extract_text_from_docx(file_path)
    elif file_path.endswith('.txt'):
        return extract_text_from_txt(file_path)
    return ""

def process_cv_folder(folder_path):
    """Processes all supported files in a folder."""
    results = []
    for filename in os.listdir(folder_path):
        if filename.startswith('~$'):
            continue
        file_path = os.path.join(folder_path, filename)
        if file_path.endswith(('.docx', '.pdf', '.txt')):
            logger.info(f"Processing {filename}...")
            raw_text = extract_text_from_file(file_path)
            if not raw_text:
                continue
            cleaned_text = clean_text(raw_text)
            extracted_info = ask_ai_to_extract_info(cleaned_text)

            # Try parsing the returned info as JSON
            try:
                extracted_info_json = json.loads(extracted_info)
                results.append({filename: extracted_info_json})
            except json.JSONDecodeError:
                logger.error(f"Invalid JSON extracted from {filename}. Skipping...")
                continue
    return results

def save_results_to_json(results, output_dir):
    """Saves the processed results to a JSON file."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    current_date = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    output_file = os.path.join(output_dir, f"cv_results_{current_date}.json")
    with open(output_file, "w", encoding="utf-8") as file:
        json.dump(results, file, indent=4, ensure_ascii=False)  # Save formatted JSON
    logger.info(f"Results saved to {output_file}")

if __name__ == "__main__":
    folder_path = r"E:\ai modle\data"  # Replace with your folder path
    output_dir = r"E:\ai modle\outputs"  # Replace with your output directory
    if not os.path.exists(folder_path):
        logger.error(f"Folder {folder_path} not found.")
    else:
        results = process_cv_folder(folder_path)
        save_results_to_json(results, output_dir)
