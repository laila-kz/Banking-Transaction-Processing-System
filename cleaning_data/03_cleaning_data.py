import csv
import re
from datetime import datetime
import os

# ============ CONFIGURATION ============
INPUT_FILE = './data/transactions_data.csv'
OUTPUT_FILE = './data/clean_data/transactions.csv'
CHUNKS_DIR = './data/clean_data/transactions_chunks'
ROWS_PER_CHUNK = 500000
IMPORT_SQL_FILE = 'load_transactions_chunks.sql'
TARGET_DATABASE = 'bank_sys_final'

CSV_COLUMNS = ['id', 'date', 'client_id', 'card_id', 'amount', 'use_chip', 
               'merchant_id', 'merchant_city', 'merchant_state', 'zip', 'mcc', 'errors']


def ensure_parent_dir(file_path):
    parent = os.path.dirname(file_path)
    if parent:
        os.makedirs(parent, exist_ok=True)


def normalize_merchant_id(value):
    """Normalize merchant_id to INT-compatible string (matches merchants table)."""
    if value is None:
        return None

    value_str = str(value).strip()
    if value_str == '':
        return None

    if value_str.endswith('.0'):
        value_str = value_str[:-2]

    if value_str.lstrip('-').isdigit():
        return str(int(value_str))

    return None


# ============ CLEANING FUNCTIONS ============
def clean_amount(value):
    """Remove $ sign and convert negative amounts properly"""
    if not value or value.strip() == '':
        return None
    
    value_str = str(value).strip()
    
    # Remove $ sign and any spaces
    cleaned = value_str.replace('$', '').replace(' ', '')
    
    # Handle negative numbers with parentheses if any
    if cleaned.startswith('(') and cleaned.endswith(')'):
        cleaned = '-' + cleaned[1:-1]
    
    try:
        # Convert to float, then format to 2 decimal places
        amount_float = float(cleaned)
        return f"{amount_float:.2f}"
    except ValueError:
        print(f"Warning: Could not convert amount '{value_str}'")
        return None

def clean_date(value):
    """Convert date string to MySQL DATETIME format (YYYY-MM-DD HH:MM:SS)"""
    if not value or value.strip() == '':
        return None
    
    value_str = str(value).strip()
    
    try:
        dt = datetime.strptime(value_str, '%Y-%m-%d %H:%M:%S')
        return dt.strftime('%Y-%m-%d %H:%M:%S')
    except ValueError:
        try:
            dt = datetime.strptime(value_str, '%Y-%m-%d %H:%M')
            return dt.strftime('%Y-%m-%d %H:%M:%S')
        except ValueError:
            return None

def clean_text(value, max_length=None):
    """Clean text fields, remove problematic characters"""
    if not value or value.strip() == '':
        return ''
    
    cleaned = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', str(value))
    cleaned = cleaned.strip()
    
    if max_length and len(cleaned) > max_length:
        cleaned = cleaned[:max_length]
    
    return cleaned


def process_large_csv():
    """Process CSV file row by row without loading into memory"""
    
    print('Starting to process transactions...')
    
    if not os.path.exists(INPUT_FILE):
        print(f"Error: Cannot find '{INPUT_FILE}'")
        raise FileNotFoundError(INPUT_FILE)
    
    file_size = os.path.getsize(INPUT_FILE) / (1024 * 1024)
    print(f'  File size: {file_size:.2f} MB')
    
    row_count = 0
    error_count = 0
    skipped_merchant_id = 0
    
    ensure_parent_dir(OUTPUT_FILE)
    
    with open(INPUT_FILE, 'r', encoding='utf-8-sig') as infile:
        sample = infile.read(1024)
        infile.seek(0)
        dialect = csv.Sniffer().sniff(sample)
        reader = csv.DictReader(infile, dialect=dialect)
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8', newline='') as outfile:
            output_columns = ['transaction_id', 'date', 'customer_id', 'card_id', 
                             'amount', 'use_chip', 'merchant_id', 'errors']
            
            writer = csv.DictWriter(outfile, fieldnames=output_columns)
            writer.writeheader()
            
            print('\nProcessing rows...')
            
            for row in reader:
                row_count += 1
                
                if row_count % 100000 == 0:
                    print(f'  Processed {row_count:,} rows...')
                
                try:
                    merchant_id_clean = normalize_merchant_id(row.get('merchant_id', ''))
                    
                    if merchant_id_clean is None and row.get('merchant_id', '').strip():
                        skipped_merchant_id += 1
                        continue
                    
                    cleaned_row = {
                        'transaction_id': row.get('id', '').strip(),
                        'date': clean_date(row.get('date', '')),
                        'customer_id': row.get('client_id', '').strip(),
                        'card_id': row.get('card_id', '').strip(),
                        'amount': clean_amount(row.get('amount', '')),
                        'use_chip': clean_text(row.get('use_chip', ''), 30),
                        'merchant_id': merchant_id_clean if merchant_id_clean else '',
                        'errors': clean_text(row.get('errors', ''))
                    }
                    
                    if not cleaned_row['transaction_id'] or not cleaned_row['date']:
                        error_count += 1
                        if error_count <= 10:
                            print(f'  Warning: Skipping row {row_count} - missing ID or date')
                        continue
                    
                    writer.writerow(cleaned_row)
                    
                except Exception as e:
                    error_count += 1
                    if error_count <= 10:
                        print(f'  Error on row {row_count}: {e}')
                    continue
    
    print('\n' + '='*50)
    print('PROCESSING COMPLETE!')
    print(f'  Total rows processed: {row_count:,}')
    print(f'  Rows cleaned: {row_count - error_count - skipped_merchant_id:,}')
    print(f'  Errors/skipped (missing data): {error_count:,}')
    print(f'  Skipped (invalid merchant_id): {skipped_merchant_id:,}')
    print(f'  Output file: {OUTPUT_FILE}')
    
    output_size = os.path.getsize(OUTPUT_FILE) / (1024 * 1024)
    print(f'  Output size: {output_size:.2f} MB')


def split_csv_into_chunks(input_csv, chunks_dir, rows_per_chunk):
    """Split CSV into chunk files for bulk import."""
    os.makedirs(chunks_dir, exist_ok=True)

    for file_name in os.listdir(chunks_dir):
        if file_name.startswith('transactions_part_') and file_name.endswith('.csv'):
            os.remove(os.path.join(chunks_dir, file_name))

    chunk_files = []
    with open(input_csv, 'r', encoding='utf-8', newline='') as infile:
        reader = csv.reader(infile)
        header = next(reader)

        chunk_index = 1
        row_in_chunk = 0
        out_file = None
        writer = None

        for row in reader:
            if row_in_chunk == 0:
                chunk_path = os.path.join(chunks_dir, f'transactions_part_{chunk_index:03d}.csv')
                out_file = open(chunk_path, 'w', encoding='utf-8', newline='')
                writer = csv.writer(out_file)
                writer.writerow(header)
                chunk_files.append(chunk_path)

            writer.writerow(row)
            row_in_chunk += 1

            if row_in_chunk >= rows_per_chunk:
                out_file.close()
                chunk_index += 1
                row_in_chunk = 0

        if out_file is not None and not out_file.closed:
            out_file.close()

    print(f'Created {len(chunk_files)} chunk file(s) in {chunks_dir}')
    return chunk_files


def to_mysql_path(path):
    """Convert Windows path to MySQL-friendly path format."""
    return os.path.abspath(path).replace('\\', '/').replace("'", "\\'")


def generate_mysql_loader_sql(chunk_files, sql_output_file, database_name):
    """Generate SQL script to load chunk files with FK handling."""
    ensure_parent_dir(sql_output_file)
    with open(sql_output_file, 'w', encoding='utf-8') as sql_file:
        sql_file.write('-- Auto-generated bulk import script for transactions chunks\n')
        sql_file.write(f'USE {database_name};\n\n')
        sql_file.write('CREATE TABLE IF NOT EXISTS transactions_staging (\n')
        sql_file.write('    transaction_id INT NOT NULL,\n')
        sql_file.write('    date DATETIME NOT NULL,\n')
        sql_file.write('    customer_id INT NULL,\n')
        sql_file.write('    card_id INT NULL,\n')
        sql_file.write('    amount DECIMAL(12,2) NULL,\n')
        sql_file.write('    use_chip VARCHAR(30) NULL,\n')
        sql_file.write('    merchant_id INT NULL,\n')
        sql_file.write('    errors TEXT NULL\n')
        sql_file.write(') ENGINE=InnoDB;\n\n')
        
        sql_file.write('TRUNCATE TABLE transactions_staging;\n')
        sql_file.write('SET autocommit = 0;\n')
        sql_file.write('SET unique_checks = 0;\n')
        sql_file.write('SET foreign_key_checks = 0;\n\n')

        for chunk_path in chunk_files:
            sql_path = to_mysql_path(chunk_path)
            sql_file.write(f"LOAD DATA LOCAL INFILE '{sql_path}'\n")
            sql_file.write('INTO TABLE transactions_staging\n')
            sql_file.write("FIELDS TERMINATED BY ','\n")
            sql_file.write('OPTIONALLY ENCLOSED BY "\\\""\n')
            sql_file.write("LINES TERMINATED BY '\\n'\n")
            sql_file.write('IGNORE 1 LINES\n')
            sql_file.write('(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)\n')
            sql_file.write('SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),\n')
            sql_file.write('    date = CAST(TRIM(@date) AS DATETIME),\n')
            sql_file.write('    customer_id = IF(TRIM(@customer_id) = \'\', NULL, CAST(TRIM(@customer_id) AS SIGNED)),\n')
            sql_file.write('    card_id = IF(TRIM(@card_id) = \'\', NULL, CAST(TRIM(@card_id) AS SIGNED)),\n')
            sql_file.write('    amount = IF(TRIM(@amount) = \'\', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),\n')
            sql_file.write('    use_chip = TRIM(@use_chip),\n')
            sql_file.write('    merchant_id = IF(TRIM(@merchant_id) = \'\', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),\n')
            sql_file.write('    errors = TRIM(@errors);\n\n')

        sql_file.write('INSERT INTO transactions (transaction_uuid, reference_number, external_transaction_id, source_system, transaction_type, status, customer_id, card_id, merchant_id, amount, currency, use_chip, transaction_date, posted_at, failure_reason)\n')
        sql_file.write("SELECT UUID(), CONCAT('LEG-', LPAD(transaction_id, 20, '0')), transaction_id, 'LEGACY_IMPORT', 'LEGACY_IMPORT', 'POSTED', customer_id, card_id, merchant_id, amount, 'USD', use_chip, date, date, NULLIF(errors, '')\n")
        sql_file.write('FROM transactions_staging\n')
        sql_file.write('WHERE transaction_id IS NOT NULL\n')
        sql_file.write('ON DUPLICATE KEY UPDATE\n')
        sql_file.write('  customer_id = VALUES(customer_id),\n')
        sql_file.write('  card_id = VALUES(card_id),\n')
        sql_file.write('  merchant_id = VALUES(merchant_id),\n')
        sql_file.write('  amount = VALUES(amount),\n')
        sql_file.write('  use_chip = VALUES(use_chip),\n')
        sql_file.write('  transaction_date = VALUES(transaction_date),\n')
        sql_file.write('  posted_at = VALUES(posted_at),\n')
        sql_file.write('  failure_reason = VALUES(failure_reason),\n')
        sql_file.write('  status = VALUES(status);\n\n')
        
        sql_file.write('COMMIT;\n')
        sql_file.write('SET foreign_key_checks = 1;\n')
        sql_file.write('SET unique_checks = 1;\n\n')
        sql_file.write('SELECT COUNT(*) AS total_transactions FROM transactions;\n')

    print(f'Generated MySQL loader SQL: {sql_output_file}')


def show_preview(file_path, lines=5):
    print(f'\nPreview of {file_path} (first {lines} rows):')
    with open(file_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f):
            if i <= lines:
                print(f'  {line.strip()}')
            else:
                break


if __name__ == '__main__':
    print('='*60)
    print('Transaction Table Bulk Import Pipeline')
    print('='*60)
    
    # Step 1: Process and clean the CSV
    process_large_csv()
    
    # Step 2: Load merchants for validation (to ensure FK compatibility)
    merchants_file = './data/clean_data/merchants.csv'
    merchants_set = set()
    if os.path.exists(merchants_file):
        with open(merchants_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                if row.get('merchant_id'):
                    merchants_set.add(row['merchant_id'])
        print(f'\nLoaded {len(merchants_set):,} merchants for FK validation')
    
    # Step 3: Split output CSV into chunks
    if os.path.exists(OUTPUT_FILE):
        chunk_files = split_csv_into_chunks(OUTPUT_FILE, CHUNKS_DIR, ROWS_PER_CHUNK)
        
        # Step 4: Generate SQL bulk-loader script
        target_db = TARGET_DATABASE
        sql_output = os.path.join('schema', IMPORT_SQL_FILE)
        generate_mysql_loader_sql(chunk_files, sql_output, target_db)
        
        # Step 5: Show preview
        show_preview(OUTPUT_FILE, lines=3)
        
        print('\n' + '='*60)
        print('PIPELINE COMPLETE!')
        print(f'Next step: Execute SQL loader in MySQL:')
        print(f'  mysql -h localhost -u root -p < {sql_output}')
        print('='*60)
    else:
        print(f'\nError: Output file not found: {OUTPUT_FILE}')