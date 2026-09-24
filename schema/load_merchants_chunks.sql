-- Auto-generated bulk import script for merchants chunks
USE bank_sys_final;

CREATE TABLE IF NOT EXISTS merchants_staging (
    merchant_id INT NOT NULL,
    flag TINYINT(1) NOT NULL
) ENGINE=InnoDB;

TRUNCATE TABLE merchants_staging;
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_001.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_002.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_003.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_004.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_005.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_006.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_007.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_008.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_009.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_010.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_011.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_012.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_013.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_014.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_015.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_016.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_017.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_018.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_019.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_020.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_021.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_022.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_023.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_024.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_025.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_026.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_027.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_028.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_029.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_030.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_031.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_032.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_033.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_034.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_035.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_036.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_037.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_038.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_039.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_040.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_041.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_042.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_043.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_044.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

LOAD DATA LOCAL INFILE 'c:/Users/kheza/Desktop/bank_system/data/clean_data/merchants_chunks/merchants_part_045.csv'
INTO TABLE merchants_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY "\""
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@merchant_id, @flag)
SET merchant_id = CAST(TRIM(@merchant_id) AS SIGNED),
    flag = CAST(TRIM(@flag) AS UNSIGNED);

INSERT INTO merchants (merchant_id, flag)
SELECT merchant_id, MAX(flag) AS flag
FROM merchants_staging
WHERE merchant_id IS NOT NULL
GROUP BY merchant_id
ON DUPLICATE KEY UPDATE flag = VALUES(flag);

COMMIT;
SET foreign_key_checks = 1;
SET unique_checks = 1;

USE bank_sys_final;
SELECT * FROM merchants limit 10;

drop table merchants2
