import hashlib
import pandas as pd
import re

# ============ CONFIGURATION ============
INPUT_FILE = './data/cards_data.csv'           
OUTPUT_FILE = './data/clean_data/cards.csv'
DATE_COLUMNS = ['expires', 'acct_open_date']
MONEY_COLUMNS = ['credit_limit']
BOOLEAN_COLUMNS = ['has_chip', 'card_on_dark_web']

# ============ CLEANING FUNCTIONS ============
def clean_money(value):
    """Remove $ and commas, convert to decimal"""
    if pd.isna(value) or value == '':
        return None
    
    value_str = str(value).strip()
    # Remove $ and commas
    cleaned = re.sub(r'[^\d\-\.]', '', value_str)
    
    if cleaned == '' or cleaned == '-':
        return None
    
    return float(cleaned)

def clean_date(value):
    """Ensure date is in MM/YYYY format"""
    if pd.isna(value) or value == '':
        return None
    
    value_str = str(value).strip()
    
    # Check if already in MM/YYYY format
    if re.match(r'^\d{1,2}/\d{4}$', value_str):
        # Pad month to 2 digits
        if len(value_str.split('/')[0]) == 1:
            month, year = value_str.split('/')
            return f"{month.zfill(2)}/{year}"
        return value_str
    else:
        print(f"Warning: Unusual date format '{value_str}'")
        return value_str

def clean_boolean(value):
    """Standardize YES/NO to consistent format"""
    if pd.isna(value) or value == '':
        return None
    
    value_str = str(value).strip().upper()
    
    if value_str in ['YES', 'Y', '1', 'TRUE']:
        return 'YES'
    elif value_str in ['NO', 'N', '0', 'FALSE']:
        return 'NO'
    else:
        print(f"Warning: Unknown boolean value '{value_str}', setting to NO")
        return 'NO'

def normalize_card_number(value):
    """Normalize a card PAN to digits only without storing the raw number."""
    if pd.isna(value) or value == '':
        return None

    cleaned = re.sub(r'[^0-9]', '', str(value))
    if cleaned == '':
        return None
    return cleaned


def card_token(value):
    """Create a deterministic token from the PAN for secure storage."""
    cleaned = normalize_card_number(value)
    if cleaned is None:
        return None
    return hashlib.sha256(cleaned.encode('utf-8')).hexdigest()


def card_last_four(value):
    """Return only the last four digits of the PAN."""
    cleaned = normalize_card_number(value)
    if cleaned is None:
        return None
    return cleaned[-4:].zfill(4)

# ============ MAIN PROCESSING ============
def main():
    print(" Reading cards CSV...")
    df = pd.read_csv(INPUT_FILE)
    print(f" Loaded {len(df)} rows")
    
    # 1. Clean credit limit ($ sign)
    print("\n Cleaning credit_limit column...")
    df['credit_limit'] = df['credit_limit'].apply(clean_money)
    
    # 2. Clean dates
    for col in DATE_COLUMNS:
        if col in df.columns:
            print(f" Cleaning {col} column...")
            df[col] = df[col].apply(clean_date)
    
    # 3. Clean boolean columns (standardize YES/NO)
    for col in BOOLEAN_COLUMNS:
        if col in df.columns:
            print(f" Cleaning {col} column...")
            df[col] = df[col].apply(clean_boolean)
    
    # 4. Tokenize the PAN and keep only the last four digits
    print("\n Securing card_number column...")
    df['card_token'] = df['card_number'].apply(card_token)
    df['card_last_four'] = df['card_number'].apply(card_last_four)
    if 'card_number' in df.columns:
        df = df.drop(columns=['card_number'])
    if 'cvv' in df.columns:
        df = df.drop(columns=['cvv'])
    
    # 5. Rename 'id' to 'card_id' to match your table
    if 'id' in df.columns:
        print("\n Renaming 'id' column to 'card_id'...")
        df = df.rename(columns={'id': 'card_id'})
    
    # 6. Rename 'client_id' to 'customer_id' to match your table
    if 'client_id' in df.columns:
        print(" Renaming 'client_id' column to 'customer_id'...")
        df = df.rename(columns={'client_id': 'customer_id'})
    
    # 7. Verify foreign key integrity (optional but recommended)
    print("\n Checking data quality...")
    print(f"   - Total rows: {len(df)}")
    print(f"   - Unique customers: {df['customer_id'].nunique()}")
    print(f"   - Null customer_ids: {df['customer_id'].isna().sum()}")
    
    # Preview results
    print("\n First 3 rows after cleaning:")
    preview_cols = ['card_id', 'customer_id', 'card_token', 'card_last_four', 'credit_limit', 'expires', 'has_chip']
    print(df[preview_cols].head(3))

    ordered_columns = [
        'card_id', 'customer_id', 'card_brand', 'card_type', 'card_token', 'card_last_four',
        'expires', 'has_chip', 'num_cards_issued', 'credit_limit', 'acct_open_date',
        'year_pin_last_changed', 'card_on_dark_web'
    ]
    existing_columns = [column for column in ordered_columns if column in df.columns]
    df = df[existing_columns]
    
    # Save cleaned CSV
    df.to_csv(OUTPUT_FILE, index=False)
    print(f"\n Cleaned file saved as: {OUTPUT_FILE}")
    

if __name__ == "__main__":
    main()