import pandas as pd
import re

# ============ CONFIGURATION ============
INPUT_FILE = './data/users_data.csv'      
OUTPUT_FILE = './data/clean_data/users.csv'      
MONEY_COLUMNS = ['yearly_income', 'total_debt', 'per_capita_income']  

# ============ FUNCTION TO CLEAN MONEY VALUES ============
def clean_money(value):
    """Remove $ and commas, convert to decimal/float"""
    if pd.isna(value) or value == '':
        return None
    
    # Convert to string if not already
    value_str = str(value)
    
    # Remove $ and commas, keep minus sign and decimal point
    cleaned = re.sub(r'[^\d\-\.]', '', value_str)
    
    # Handle empty strings after cleaning
    if cleaned == '' or cleaned == '-':
        return None
    
    # Convert to float
    return float(cleaned)

# ============ MAIN PROCESSING ============
print(f"Reading {INPUT_FILE}...")
df = pd.read_csv(INPUT_FILE)

print(f"Original data shape: {df.shape}")
print(f"Columns found: {list(df.columns)}")

# Clean each money column
for col in MONEY_COLUMNS:
    if col in df.columns:
        print(f"Cleaning column: {col}")
        df[col] = df[col].apply(clean_money)
    else:
        print(f"Warning: Column '{col}' not found in CSV. Available columns: {list(df.columns)}")

# Display first few rows to verify
print("\nFirst 5 rows after cleaning:")
print(df[MONEY_COLUMNS].head())

# Save to new CSV
df.to_csv(OUTPUT_FILE, index=False)
print(f"\n✅ Cleaned file saved as: {OUTPUT_FILE}")