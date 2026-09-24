
import csv
import json
import os

# ============ CONFIGURATION ============
INPUT_FILE = './data/train_fraud_labels.json'
OUTPUT_FILE = './data/clean_data/merchants.csv'
CHUNKS_DIR = './data/clean_data/merchants_chunks'
ROWS_PER_CHUNK = 200000
IMPORT_SQL_FILE = './schema/load_merchants_chunks.sql'
TARGET_DATABASE = 'bank_sys_final'


def ensure_parent_dir(file_path):
    parent = os.path.dirname(file_path)
    if parent:
        os.makedirs(parent, exist_ok=True)


def normalize_merchant_id(value):
    """Normalize merchant_id to an integer string compatible with MySQL INT."""
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


def normalize_flag(value):
    """Convert flag to 0/1 integer for clean import into TINYINT(1)."""
    if value is None:
        return 0

    value_str = str(value).strip().lower()
    if value_str in {'1', 'true', 'yes'}:
        return 1
    if value_str in {'0', 'false', 'no'}:
        return 0

    try:
        return 1 if float(value_str) > 0 else 0
    except ValueError:
        return 0


def build_merchants_csv():
    print('Starting extraction...')

    if not os.path.exists(INPUT_FILE):
        print(f"Error: Cannot find '{INPUT_FILE}'")
        raise FileNotFoundError(INPUT_FILE)

    with open(INPUT_FILE, 'r', encoding='utf-8') as json_file:
        print(f'Reading {INPUT_FILE}...')
        data = json.load(json_file)

    target_data = data.get('target', {})
    print(f'  Found {len(target_data):,} merchants in source')

    ensure_parent_dir(OUTPUT_FILE)
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(['merchant_id', 'flag'])

        seen_merchant_ids = set()
        duplicate_count = 0
        skipped_empty_id_count = 0
        skipped_invalid_id_count = 0
        written_count = 0

        for merchant_id, flag in target_data.items():
            merchant_id_clean = normalize_merchant_id(merchant_id)
            flag_clean = normalize_flag(flag)

            if merchant_id is None or str(merchant_id).strip() == '':
                skipped_empty_id_count += 1
                continue

            if merchant_id_clean is None:
                skipped_invalid_id_count += 1
                continue

            if merchant_id_clean in seen_merchant_ids:
                duplicate_count += 1
                continue

            seen_merchant_ids.add(merchant_id_clean)
            writer.writerow([merchant_id_clean, flag_clean])
            written_count += 1

    print(f'Done! Created {OUTPUT_FILE}')
    print(f'  Written unique merchants: {written_count:,}')
    print(f'  Duplicates removed: {duplicate_count:,}')
    print(f'  Skipped empty merchant_id: {skipped_empty_id_count:,}')
    print(f'  Skipped invalid merchant_id: {skipped_invalid_id_count:,}')

    # Streaming check keeps memory usage low even for large files.
    seen = set()
    duplicate_in_output = 0
    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            mid = row['merchant_id']
            if mid in seen:
                duplicate_in_output += 1
            else:
                seen.add(mid)

    if duplicate_in_output == 0:
        print('  Output duplicate check: PASS (no duplicate merchant_id values)')
    else:
        print(f'  Output duplicate check: FAIL ({duplicate_in_output} duplicates found)')


def split_csv_into_chunks(input_csv, chunks_dir, rows_per_chunk):
    os.makedirs(chunks_dir, exist_ok=True)

    # Clean up old chunk files so imports do not load stale parts.
    for file_name in os.listdir(chunks_dir):
        if file_name.startswith('merchants_part_') and file_name.endswith('.csv'):
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
                chunk_path = os.path.join(chunks_dir, f'merchants_part_{chunk_index:03d}.csv')
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
    ensure_parent_dir(sql_output_file)
    with open(sql_output_file, 'w', encoding='utf-8') as sql_file:
        sql_file.write('-- Auto-generated bulk import script for merchants chunks\n')
        sql_file.write(f'USE {database_name};\n\n')
        sql_file.write('CREATE TABLE IF NOT EXISTS merchants_staging (\n')
        sql_file.write('    merchant_id INT NOT NULL,\n')
        sql_file.write('    flag TINYINT(1) NOT NULL\n')
        sql_file.write(') ENGINE=InnoDB;\n\n')
        sql_file.write('TRUNCATE TABLE merchants_staging;\n')
        sql_file.write('SET autocommit = 0;\n')
        sql_file.write('SET unique_checks = 0;\n')
        sql_file.write('SET foreign_key_checks = 0;\n\n')

        for chunk_path in chunk_files:
            sql_path = to_mysql_path(chunk_path)
            sql_file.write(f"LOAD DATA LOCAL INFILE '{sql_path}'\n")
            sql_file.write('INTO TABLE merchants_staging\n')
            sql_file.write("FIELDS TERMINATED BY ','\n")
            sql_file.write('OPTIONALLY ENCLOSED BY "\\\""\n')
            sql_file.write("LINES TERMINATED BY '\\n'\n")
            sql_file.write('IGNORE 1 LINES\n')
            sql_file.write('(@merchant_id, @flag)\n')
            sql_file.write('SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),\n')
            sql_file.write('    flag = CAST(TRIM(@flag) AS UNSIGNED);\n\n')

        sql_file.write('INSERT INTO merchants (merchant_id, flag)\n')
        sql_file.write('SELECT merchant_id, MAX(flag) AS flag\n')
        sql_file.write('FROM merchants_staging\n')
        sql_file.write('WHERE merchant_id IS NOT NULL\n')
        sql_file.write('GROUP BY merchant_id\n')
        sql_file.write('ON DUPLICATE KEY UPDATE flag = VALUES(flag);\n\n')
        sql_file.write('COMMIT;\n')
        sql_file.write('SET foreign_key_checks = 1;\n')
        sql_file.write('SET unique_checks = 1;\n')

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
    build_merchants_csv()
    chunk_files = split_csv_into_chunks(OUTPUT_FILE, CHUNKS_DIR, ROWS_PER_CHUNK)
    generate_mysql_loader_sql(chunk_files, IMPORT_SQL_FILE, TARGET_DATABASE)
    show_preview(OUTPUT_FILE, lines=5)