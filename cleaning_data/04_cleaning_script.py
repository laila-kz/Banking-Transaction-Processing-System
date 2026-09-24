import csv
import json
import os
import re

# ============ CONFIGURATION ============
INPUT_FILE = './data/mcc_codes.json'      # Your MCC JSON file
OUTPUT_FILE = './data/clean_data/mcc.csv' # Output CSV file

# ============ CLEANING FUNCTIONS ============
def clean_mcc_code(value):
    """Clean MCC code - extract 4 digits"""
    if value is None or value == '':
        return None
    
    # Convert to string and extract only digits
    cleaned = re.sub(r'[^\d]', '', str(value))
    
    # MCC codes are typically 4 digits
    if len(cleaned) >= 4:
        cleaned = cleaned[:4]
    elif len(cleaned) > 0:
        cleaned = cleaned.zfill(4)  # Pad with zeros if needed
    else:
        return None
    
    return cleaned

def clean_text(value, max_length=100):
    """Clean text fields"""
    if value is None or value == '':
        return ''
    
    # Convert to string and clean
    cleaned = str(value).strip()
    
    # Remove any control characters
    cleaned = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', cleaned)
    
    # Truncate if needed
    if len(cleaned) > max_length:
        cleaned = cleaned[:max_length]
    
    return cleaned

# ============ CONVERT JSON TO CSV ============
def convert_mcc_json_to_csv():
    """Convert MCC JSON to CSV"""
    
    print("="*60)
    print(" MCC JSON to CSV Converter")
    print("="*60)
    
    # Check if input file exists
    if not os.path.exists(INPUT_FILE):
        print(f" Error: File '{INPUT_FILE}' not found!")
        print(f"   Current directory: {os.getcwd()}")
        return False
    
    print(f" Reading: {INPUT_FILE}")
    
    try:
        # Read JSON file
        with open(INPUT_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        print(f" JSON loaded successfully")
        
        # Prepare rows for CSV
        rows = []
        
        # Handle different JSON formats
        if isinstance(data, dict):
            # Check if it's key-value pairs like {"1234": "Description"}
            first_key = next(iter(data.keys()))
            if isinstance(data[first_key], str):
                # Format: {"5499": "Miscellaneous Food Stores"}
                print(f" Detected format: Code-Description pairs")
                for code, description in data.items():
                    rows.append({
                        'mcc_code': clean_mcc_code(code),
                        'mcc_description': clean_text(description)
                    })
            else:
                # Format: {"mcc_codes": [{"code": "1234", "description": "..."}]}
                print(f" Detected format: Nested array")
                for key, value in data.items():
                    if isinstance(value, list):
                        for item in value:
                            if isinstance(item, dict):
                                code = item.get('code') or item.get('mcc_code') or item.get('id')
                                desc = item.get('description') or item.get('desc') or item.get('name')
                                rows.append({
                                    'mcc_code': clean_mcc_code(code),
                                    'mcc_description': clean_text(desc)
                                })
        
        elif isinstance(data, list):
            # Format: [{"code": "1234", "description": "..."}]
            print(f" Detected format: Array of objects")
            for item in data:
                if isinstance(item, dict):
                    code = item.get('code') or item.get('mcc_code') or item.get('id')
                    desc = item.get('description') or item.get('desc') or item.get('name')
                    rows.append({
                        'mcc_code': clean_mcc_code(code),
                        'mcc_description': clean_text(desc)
                    })
        
        else:
            print(f" Unsupported JSON format: {type(data)}")
            return False
        
        # Remove any rows with missing MCC code
        original_count = len(rows)
        rows = [row for row in rows if row['mcc_code'] is not None]
        
        print(f" Found {original_count} MCC codes")
        print(f"   Valid codes: {len(rows)}")
        
        if len(rows) == 0:
            print(" No valid MCC codes found!")
            return False
        
        # Create output directory if it doesn't exist
        os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
        
        # Write to CSV
        with open(OUTPUT_FILE, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=['mcc_code', 'mcc_description'])
            writer.writeheader()
            writer.writerows(rows)
        
        print(f" Saved to: {OUTPUT_FILE}")
        
        # Show preview
        print(f"\n Preview (first 10 rows):")
        with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f):
                if i < 11:  # Header + 10 rows
                    print(f"   {line.strip()}")
                else:
                    break
        
        # Show statistics
        print(f"\n Statistics:")
        print(f"   Total MCC codes: {len(rows)}")
        print(f"   Unique codes: {len(set(row['mcc_code'] for row in rows))}")
        
        return True
        
    except json.JSONDecodeError as e:
        print(f" JSON parsing error: {e}")
        return False
    except Exception as e:
        print(f" Unexpected error: {e}")
        return False

# ============ MAIN ============
if __name__ == "__main__":
    success = convert_mcc_json_to_csv()
    
    if success:
        print("\n" + "="*60)
        print(" Conversion successful!")
    else:
        print("\n Conversion failed!")