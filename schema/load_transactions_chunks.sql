-- Auto-generated bulk import script for transactions chunks
USE bank_sys_final;

CREATE TABLE IF NOT EXISTS transactions_staging (
    transaction_id INT NOT NULL,
    date DATETIME NOT NULL,
    customer_id INT NULL,
    card_id INT NULL,
    amount DECIMAL(12,2) NULL,
    use_chip VARCHAR(30) NULL,
    merchant_id INT NULL,
    errors TEXT NULL
) ENGINE=InnoDB;

TRUNCATE TABLE transactions_staging;
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_001.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_002.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_003.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_004.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_005.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_006.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_007.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_008.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_009.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_010.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_011.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_012.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_013.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_014.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_015.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_016.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_017.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_018.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_019.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_020.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_021.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_022.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_023.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_024.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_025.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_026.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/transactions_chunks/transactions_part_027.csv'
INTO TABLE transactions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@transaction_id, @date, @customer_id, @card_id, @amount, @use_chip, @merchant_id, @errors)
SET transaction_id = CAST(TRIM(@transaction_id) AS SIGNED),
    date = CAST(TRIM(@date) AS DATETIME),
    customer_id = IF(TRIM(@customer_id) = '', NULL, CAST(TRIM(@customer_id) AS SIGNED)),
    card_id = IF(TRIM(@card_id) = '', NULL, CAST(TRIM(@card_id) AS SIGNED)),
    amount = IF(TRIM(@amount) = '', NULL, CAST(TRIM(@amount) AS DECIMAL(12,2))),
    use_chip = TRIM(@use_chip),
    merchant_id = IF(TRIM(@merchant_id) = '', NULL, CAST(TRIM(@merchant_id) AS SIGNED)),
    errors = TRIM(@errors);

INSERT INTO transactions (
  transaction_uuid,
  reference_number,
  external_transaction_id,
  source_system,
  transaction_type,
  status,
  customer_id,
  card_id,
  merchant_id,
  amount,
  currency,
  use_chip,
  transaction_date,
  posted_at,
  failure_reason
)
SELECT
  UUID(),
  CONCAT('LEG-', LPAD(transaction_id, 20, '0')),
  transaction_id,
  'LEGACY_IMPORT',
  'LEGACY_IMPORT',
  'POSTED',
  customer_id,
  card_id,
  merchant_id,
  amount,
  'USD',
  use_chip,
  date,
  date,
  NULLIF(errors, '')
FROM transactions_staging
WHERE transaction_id IS NOT NULL
ON DUPLICATE KEY UPDATE
  customer_id = VALUES(customer_id),
  card_id = VALUES(card_id),
  merchant_id = VALUES(merchant_id),
  amount = VALUES(amount),
  use_chip = VALUES(use_chip),
  transaction_date = VALUES(transaction_date),
  posted_at = VALUES(posted_at),
  failure_reason = VALUES(failure_reason),
  status = VALUES(status);

COMMIT;
SET foreign_key_checks = 1;
SET unique_checks = 1;

SELECT *  FROM transactions limit 10;
