import fitz  # PyMuPDF
import sys

def extract_text(pdf_path, num_pages=5):
    try:
        doc = fitz.open(pdf_path)
        print(f"Total pages: {len(doc)}")
        for i in range(min(num_pages, len(doc))):
            page = doc[i]
            text = page.get_text()
            print(f"--- Page {i + 1} ---")
            print(text)
            print("-" * 40)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    pdf_path = r"c:\Users\Wits student\OneDrive\Desktop\prac\MathGrade12\exercise\2025 WTS TERM ONE CAMP-20260220T015514Z-1-001\2025 WTS TERM ONE CAMP\2025 WTS  12 MATHS  T 01  BOOTCAMP.pdf"
    extract_text(pdf_path, 10)
